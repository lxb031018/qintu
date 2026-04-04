/**
 * 导航任务管理路由
 * 
 * 路由列表：
 * POST   /api/tasks               - 创建导航任务（发送者）
 * GET    /api/tasks/my            - 获取我的任务列表
 * GET    /api/tasks/pending       - 获取待处理的任务（接收者）
 * GET    /api/tasks/:taskId       - 获取任务详情
 * POST   /api/tasks/:taskId/accept     - 接受任务（接收者）
 * POST   /api/tasks/:taskId/start      - 开始导航（接收者）
 * POST   /api/tasks/:taskId/finish     - 完成任务（接收者）
 * POST   /api/tasks/:taskId/cancel     - 取消任务（发送者/接收者）
 * PUT    /api/tasks/:taskId/route      - 更新路线（发送者修改路线）
 */

const express = require('express');
const router = express.Router();
const { query, transaction } = require('../lib/database');
const { success, validationError, error, notFound } = require('../lib/response');
const { authMiddleware } = require('../middleware/auth');
const { v4: uuidv4 } = require('uuid');

/**
 * POST /api/tasks
 * 创建导航任务（发送者下发路线）
 * 
 * 需要认证（发送者角色）
 * 请求体：
 * {
 *   "receiver_openid": "xxx",           // 必需，接收者 openid
 *   "start_name": "当前位置",            // 可选
 *   "start_latitude": 39.9042,          // 可选
 *   "start_longitude": 116.4074,        // 可选
 *   "start_address": "北京市朝阳区...",  // 可选
 *   "end_name": "北京站",                // 必需
 *   "end_latitude": 39.9042,            // 必需
 *   "end_longitude": 116.4074,          // 必需
 *   "end_address": "北京市东城区...",    // 可选
 *   "route_data": {...},                // 必需，高德地图路线 JSON
 *   "route_summary": {...},             // 可选，路线摘要
 *   "transport_mode": "drive",          // 可选，默认 drive
 *   "distance_meters": 15300,           // 可选
 *   "duration_seconds": 1920            // 可选
 * }
 */
router.post('/', authMiddleware, async (req, res) => {
  try {
    const senderOpenid = req.user.openid;
    const {
      receiver_openid,
      start_name,
      start_latitude,
      start_longitude,
      start_address,
      end_name,
      end_latitude,
      end_longitude,
      end_address,
      route_data,
      route_summary,
      transport_mode,
      distance_meters,
      duration_seconds
    } = req.body;

    // 验证发送者角色
    if (req.user.user_type === 'receiver') {
      return error(res, '接收者角色无法创建导航任务', 'PERMISSION_DENIED', 403);
    }

    // 参数验证
    if (!receiver_openid || !end_name || end_latitude === undefined || end_longitude === undefined) {
      return validationError(res, '缺少必需参数：receiver_openid, end_name, end_latitude, end_longitude');
    }

    if (!route_data) {
      return validationError(res, 'route_data 是必需参数（高德地图路线数据）');
    }

    // 验证绑定关系
    const bindings = await query(
      `SELECT id FROM user_bindings 
       WHERE sender_openid = ? AND receiver_openid = ? AND status = 'active'`,
      [senderOpenid, receiver_openid]
    );

    if (bindings.length === 0) {
      return error(res, '与该接收者没有绑定关系', 'NO_BINDING', 403);
    }

    // 检查接收者是否有进行中的任务
    const existingTasks = await query(
      `SELECT task_id, status FROM navigation_tasks 
       WHERE receiver_openid = ? AND status IN ('waiting', 'accepted', 'navigating')`,
      [receiver_openid]
    );

    if (existingTasks.length > 0) {
      return error(
        res, 
        `该接收者有进行中的任务（${existingTasks[0].status}）`, 
        'TASK_IN_PROGRESS', 
        409
      );
    }

    // 生成任务 ID
    const taskId = uuidv4();

    // 创建任务
    await query(
      `INSERT INTO navigation_tasks (
        task_id, sender_openid, receiver_openid, status,
        start_name, start_latitude, start_longitude, start_address,
        end_name, end_latitude, end_longitude, end_address,
        route_data, route_summary, transport_mode,
        distance_meters, duration_seconds, created_at
      ) VALUES (
        ?, ?, ?, 'waiting',
        ?, ?, ?, ?,
        ?, ?, ?, ?,
        ?, ?, ?,
        ?, ?, NOW()
      )`,
      [
        taskId, senderOpenid, receiver_openid,
        start_name || null, start_latitude || null, start_longitude || null, start_address || null,
        end_name, end_latitude, end_longitude, end_address || null,
        typeof route_data === 'object' ? JSON.stringify(route_data) : route_data,
        route_summary ? (typeof route_summary === 'object' ? JSON.stringify(route_summary) : route_summary) : null,
        transport_mode || 'drive',
        distance_meters || null,
        duration_seconds || null
      ]
    );

    // 返回创建的任务
    const tasks = await query(
      `SELECT * FROM navigation_tasks WHERE task_id = ?`,
      [taskId]
    );

    return success(res, {
      message: '导航任务已创建并发送给接收者',
      task: tasks[0]
    }, 201);
  } catch (err) {
    console.error('创建导航任务失败:', err);
    return error(res, '创建导航任务失败', 'CREATE_TASK_FAILED', 500);
  }
});

/**
 * GET /api/tasks/my
 * 获取我的任务列表
 * 
 * 需要认证
 * 查询参数：
 * - role: 'sender' 或 'receiver'（默认根据用户类型自动判断）
 * - status: 过滤状态（可选）
 * - page: 页码（默认 1）
 * - limit: 每页数量（默认 20）
 */
router.get('/my', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const { role, status, page = 1, limit = 20 } = req.query;

    // 确定查询角色
    const queryRole = role || (req.user.user_type === 'receiver' ? 'receiver' : 'sender');
    const offset = (parseInt(page) - 1) * parseInt(limit);

    // 构建查询
    let sql;
    let params;

    if (queryRole === 'sender') {
      // 查询作为发送者发出的任务
      sql = `
        SELECT t.*, 
               r.nickname as receiver_nickname,
               r.phone as receiver_phone
        FROM navigation_tasks t
        INNER JOIN users r ON t.receiver_openid = r.openid
        WHERE t.sender_openid = ?
        ${status ? 'AND t.status = ?' : ''}
        ORDER BY t.created_at DESC
        LIMIT ? OFFSET ?
      `;
      params = status ? [openid, status, parseInt(limit), offset] : [openid, parseInt(limit), offset];
    } else {
      // 查询作为接收者接收的任务
      sql = `
        SELECT t.*, 
               s.nickname as sender_nickname,
               s.phone as sender_phone
        FROM navigation_tasks t
        INNER JOIN users s ON t.sender_openid = s.openid
        WHERE t.receiver_openid = ?
        ${status ? 'AND t.status = ?' : ''}
        ORDER BY t.created_at DESC
        LIMIT ? OFFSET ?
      `;
      params = status ? [openid, status, parseInt(limit), offset] : [openid, parseInt(limit), offset];
    }

    const tasks = await query(sql, params);

    // 查询总数
    let countSql;
    let countParams;
    
    if (queryRole === 'sender') {
      countSql = `SELECT COUNT(*) as total FROM navigation_tasks WHERE sender_openid = ? ${status ? 'AND status = ?' : ''}`;
      countParams = status ? [openid, status] : [openid];
    } else {
      countSql = `SELECT COUNT(*) as total FROM navigation_tasks WHERE receiver_openid = ? ${status ? 'AND status = ?' : ''}`;
      countParams = status ? [openid, status] : [openid];
    }

    const countResult = await query(countSql, countParams);
    const total = countResult[0].total;

    return success(res, {
      total,
      page: parseInt(page),
      limit: parseInt(limit),
      tasks
    });
  } catch (err) {
    console.error('获取任务列表失败:', err);
    return error(res, '获取任务列表失败', 'GET_TASKS_FAILED', 500);
  }
});

/**
 * GET /api/tasks/pending
 * 获取待处理的任务（接收者专用）
 * 
 * 需要认证（接收者角色）
 * 返回所有 waiting 状态的任务
 */
router.get('/pending', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;

    const tasks = await query(
      `SELECT t.*, 
              s.nickname as sender_nickname,
              s.phone as sender_phone,
              TIMESTAMPDIFF(MINUTE, t.created_at, NOW()) as minutes_waiting
       FROM navigation_tasks t
       INNER JOIN users s ON t.sender_openid = s.openid
       WHERE t.receiver_openid = ? AND t.status = 'waiting'
       ORDER BY t.created_at DESC`,
      [openid]
    );

    return success(res, {
      total: tasks.length,
      tasks
    });
  } catch (err) {
    console.error('获取待处理任务失败:', err);
    return error(res, '获取待处理任务失败', 'GET_PENDING_FAILED', 500);
  }
});

/**
 * GET /api/tasks/:taskId
 * 获取任务详情
 * 
 * 需要认证（任务参与者）
 */
router.get('/:taskId', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const taskId = req.params.taskId;

    const tasks = await query(
      `SELECT t.*, 
              s.nickname as sender_nickname, s.phone as sender_phone,
              r.nickname as receiver_nickname, r.phone as receiver_phone
       FROM navigation_tasks t
       INNER JOIN users s ON t.sender_openid = s.openid
       INNER JOIN users r ON t.receiver_openid = r.openid
       WHERE t.task_id = ?`,
      [taskId]
    );

    if (tasks.length === 0) {
      return notFound(res, '任务不存在');
    }

    const task = tasks[0];

    // 验证权限
    if (task.sender_openid !== openid && task.receiver_openid !== openid) {
      return error(res, '无权查看此任务', 'PERMISSION_DENIED', 403);
    }

    // 解析 JSON 字段
    if (task.route_data && typeof task.route_data === 'string') {
      task.route_data = JSON.parse(task.route_data);
    }
    if (task.route_summary && typeof task.route_summary === 'string') {
      task.route_summary = JSON.parse(task.route_summary);
    }

    return success(res, task);
  } catch (err) {
    console.error('获取任务详情失败:', err);
    return error(res, '获取任务详情失败', 'GET_TASK_FAILED', 500);
  }
});

/**
 * POST /api/tasks/:taskId/accept
 * 接受任务（接收者操作）
 */
router.post('/:taskId/accept', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const taskId = req.params.taskId;

    // 验证接收者角色
    if (req.user.user_type === 'sender') {
      return error(res, '发送者角色无法接受任务', 'PERMISSION_DENIED', 403);
    }

    // 查找任务
    const tasks = await query(
      'SELECT * FROM navigation_tasks WHERE task_id = ?',
      [taskId]
    );

    if (tasks.length === 0) {
      return notFound(res, '任务不存在');
    }

    const task = tasks[0];

    // 验证权限
    if (task.receiver_openid !== openid) {
      return error(res, '无权操作此任务', 'PERMISSION_DENIED', 403);
    }

    // 验证状态
    if (task.status !== 'waiting') {
      return error(res, `任务状态为 ${task.status}，无法接受`, 'INVALID_STATUS', 400);
    }

    // 更新状态
    await query(
      `UPDATE navigation_tasks 
       SET status = 'accepted', accepted_at = NOW()
       WHERE task_id = ?`,
      [taskId]
    );

    return success(res, { message: '任务已接受' });
  } catch (err) {
    console.error('接受任务失败:', err);
    return error(res, '接受任务失败', 'ACCEPT_TASK_FAILED', 500);
  }
});

/**
 * POST /api/tasks/:taskId/start
 * 开始导航（接收者操作）
 */
router.post('/:taskId/start', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const taskId = req.params.taskId;

    const tasks = await query(
      'SELECT * FROM navigation_tasks WHERE task_id = ?',
      [taskId]
    );

    if (tasks.length === 0) {
      return notFound(res, '任务不存在');
    }

    const task = tasks[0];

    if (task.receiver_openid !== openid) {
      return error(res, '无权操作此任务', 'PERMISSION_DENIED', 403);
    }

    if (task.status !== 'accepted') {
      return error(res, `任务状态为 ${task.status}，无法开始导航`, 'INVALID_STATUS', 400);
    }

    await query(
      `UPDATE navigation_tasks 
       SET status = 'navigating', started_at = NOW()
       WHERE task_id = ?`,
      [taskId]
    );

    return success(res, { message: '导航已开始' });
  } catch (err) {
    console.error('开始导航失败:', err);
    return error(res, '开始导航失败', 'START_NAV_FAILED', 500);
  }
});

/**
 * POST /api/tasks/:taskId/finish
 * 完成任务（接收者操作）
 */
router.post('/:taskId/finish', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const taskId = req.params.taskId;

    const tasks = await query(
      'SELECT * FROM navigation_tasks WHERE task_id = ?',
      [taskId]
    );

    if (tasks.length === 0) {
      return notFound(res, '任务不存在');
    }

    const task = tasks[0];

    if (task.receiver_openid !== openid) {
      return error(res, '无权操作此任务', 'PERMISSION_DENIED', 403);
    }

    if (!['accepted', 'navigating'].includes(task.status)) {
      return error(res, `任务状态为 ${task.status}，无法完成`, 'INVALID_STATUS', 400);
    }

    await query(
      `UPDATE navigation_tasks 
       SET status = 'finished', finished_at = NOW()
       WHERE task_id = ?`,
      [taskId]
    );

    return success(res, { message: '导航已完成' });
  } catch (err) {
    console.error('完成任务失败:', err);
    return error(res, '完成任务失败', 'FINISH_TASK_FAILED', 500);
  }
});

/**
 * POST /api/tasks/:taskId/cancel
 * 取消任务（发送者或接收者）
 * 
 * 请求体：
 * {
 *   "reason": "走错路了"  // 可选
 * }
 */
router.post('/:taskId/cancel', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const taskId = req.params.taskId;
    const { reason } = req.body;

    const tasks = await query(
      'SELECT * FROM navigation_tasks WHERE task_id = ?',
      [taskId]
    );

    if (tasks.length === 0) {
      return notFound(res, '任务不存在');
    }

    const task = tasks[0];

    // 验证权限
    if (task.sender_openid !== openid && task.receiver_openid !== openid) {
      return error(res, '无权操作此任务', 'PERMISSION_DENIED', 403);
    }

    // 确定取消方
    const cancelledBy = task.sender_openid === openid ? 'sender' : 'receiver';

    // 验证状态
    if (!['waiting', 'accepted', 'navigating'].includes(task.status)) {
      return error(res, `任务状态为 ${task.status}，无法取消`, 'INVALID_STATUS', 400);
    }

    await query(
      `UPDATE navigation_tasks 
       SET status = 'cancelled', cancelled_at = NOW(), 
           cancel_reason = ?, cancelled_by = ?
       WHERE task_id = ?`,
      [reason || null, cancelledBy, taskId]
    );

    return success(res, { message: '任务已取消' });
  } catch (err) {
    console.error('取消任务失败:', err);
    return error(res, '取消任务失败', 'CANCEL_TASK_FAILED', 500);
  }
});

/**
 * PUT /api/tasks/:taskId/route
 * 更新路线（发送者修改路线，中途干预）
 * 
 * 需要认证（发送者角色）
 * 请求体：
 * {
 *   "route_data": {...},           // 必需，新路线数据
 *   "route_summary": {...},        // 可选，新路线摘要
 *   "distance_meters": 16000,      // 可选
 *   "duration_seconds": 2000       // 可选
 * }
 */
router.put('/:taskId/route', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const taskId = req.params.taskId;
    const { route_data, route_summary, distance_meters, duration_seconds } = req.body;

    // 验证发送者角色
    if (req.user.user_type === 'receiver') {
      return error(res, '接收者角色无法更新路线', 'PERMISSION_DENIED', 403);
    }

    if (!route_data) {
      return validationError(res, 'route_data 是必需参数');
    }

    const tasks = await query(
      'SELECT * FROM navigation_tasks WHERE task_id = ?',
      [taskId]
    );

    if (tasks.length === 0) {
      return notFound(res, '任务不存在');
    }

    const task = tasks[0];

    // 验证权限
    if (task.sender_openid !== openid) {
      return error(res, '无权操作此任务', 'PERMISSION_DENIED', 403);
    }

    // 验证状态（只有进行中的任务可以更新路线）
    if (!['accepted', 'navigating'].includes(task.status)) {
      return error(res, `任务状态为 ${task.status}，无法更新路线`, 'INVALID_STATUS', 400);
    }

    // 更新路线
    await query(
      `UPDATE navigation_tasks 
       SET route_data = ?, route_summary = ?, 
           distance_meters = ?, duration_seconds = ?
       WHERE task_id = ?`,
      [
        typeof route_data === 'object' ? JSON.stringify(route_data) : route_data,
        route_summary ? (typeof route_summary === 'object' ? JSON.stringify(route_summary) : route_summary) : null,
        distance_meters || null,
        duration_seconds || null,
        taskId
      ]
    );

    return success(res, { message: '路线已更新' });
  } catch (err) {
    console.error('更新路线失败:', err);
    return error(res, '更新路线失败', 'UPDATE_ROUTE_FAILED', 500);
  }
});

module.exports = router;
