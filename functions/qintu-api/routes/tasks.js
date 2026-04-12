/**
 * 导航任务管理路由
 *
 * 使用 CloudBase MySQL RESTful API
 * 路由列表：
 * POST   /api/tasks                       - 创建导航任务（发送者）
 * GET    /api/tasks/my                    - 获取我的任务列表
 * GET    /api/tasks/pending               - 获取待处理的任务（接收者）
 * GET    /api/tasks/:taskId               - 获取任务详情
 * POST   /api/tasks/:taskId/accept        - 接受任务（接收者）
 * POST   /api/tasks/:taskId/start         - 开始导航（接收者）
 * POST   /api/tasks/:taskId/finish        - 完成任务（接收者）
 * POST   /api/tasks/:taskId/cancel        - 取消任务（发送者/接收者）
 * PUT    /api/tasks/:taskId/route         - 更新路线（发送者修改路线）
 */

const express = require('express');
const router = express.Router();
const { getTable, insertTable, updateTable } = require('../lib/database');
const { success, validationError, error, notFound } = require('../lib/response');
const { authMiddleware } = require('../middleware/auth');
const { v4: uuidv4 } = require('uuid');

// ==========================================
// 辅助函数
// ==========================================

/**
 * 根据 task_id 获取任务（RESTful API 过滤器方式）
 */
async function getTaskByTaskId(taskId) {
  const result = await getTable('navigation_tasks', {
    filters: { task_id: taskId }
  });
  return Array.isArray(result) ? result[0] : result;
}

/**
 * 解析任务中的 JSON 字段
 */
function parseTaskJsonFields(task) {
  if (!task) return task;
  if (task.route_data && typeof task.route_data === 'string') {
    try { task.route_data = JSON.parse(task.route_data); } catch (e) { /* ignore */ }
  }
  if (task.route_summary && typeof task.route_summary === 'string') {
    try { task.route_summary = JSON.parse(task.route_summary); } catch (e) { /* ignore */ }
  }
  return task;
}

// ==========================================
// 路由定义
// ==========================================

/**
 * POST /api/tasks
 * 创建导航任务（发送者下发路线）
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
    const bindings = await getTable('user_bindings', {
      filters: {
        sender_openid: senderOpenid,
        receiver_openid: receiver_openid,
        status: 'active'
      }
    });

    if (!Array.isArray(bindings) || bindings.length === 0) {
      return error(res, '与该接收者没有绑定关系', 'NO_BINDING', 403);
    }

    // 检查接收者是否有进行中的任务
    const existingTasks = await getTable('navigation_tasks', {
      filters: {
        receiver_openid: receiver_openid
      }
    });

    const inProgressTasks = Array.isArray(existingTasks)
      ? existingTasks.filter(t => ['waiting', 'accepted', 'navigating'].includes(t.status))
      : [];

    if (inProgressTasks.length > 0) {
      return error(
        res,
        `该接收者有进行中的任务（${inProgressTasks[0].status}）`,
        'TASK_IN_PROGRESS',
        409
      );
    }

    // 生成任务 ID
    const taskId = uuidv4();
    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');

    // 创建任务
    const taskData = {
      task_id: taskId,
      sender_openid: senderOpenid,
      receiver_openid: receiver_openid,
      status: 'waiting',
      start_name: start_name || null,
      start_latitude: start_latitude || null,
      start_longitude: start_longitude || null,
      start_address: start_address || null,
      end_name: end_name,
      end_latitude: end_latitude,
      end_longitude: end_longitude,
      end_address: end_address || null,
      route_data: typeof route_data === 'object' ? JSON.stringify(route_data) : route_data,
      route_summary: route_summary ? (typeof route_summary === 'object' ? JSON.stringify(route_summary) : route_summary) : null,
      transport_mode: transport_mode || 'drive',
      distance_meters: distance_meters || null,
      duration_seconds: duration_seconds || null,
      created_at: now
    };

    await insertTable('navigation_tasks', taskData);

    return success(res, {
      message: '导航任务已创建并发送给接收者',
      task: { ...taskData, route_data, route_summary }
    }, 201);
  } catch (err) {
    console.error('创建导航任务失败:', err);
    return error(res, '创建导航任务失败', 'CREATE_TASK_FAILED', 500);
  }
});

/**
 * GET /api/tasks/my
 * 获取我的任务列表
 */
router.get('/my', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const { role, status, page = 1, limit = 20 } = req.query;

    const pageNum = Math.max(1, parseInt(page) || 1);
    const limitNum = Math.min(100, Math.max(1, parseInt(limit) || 20));

    // 确定查询角色
    const queryRole = role || (req.user.user_type === 'receiver' ? 'receiver' : 'sender');
    const filterKey = queryRole === 'sender' ? 'sender_openid' : 'receiver_openid';

    // 构建过滤条件
    const filters = { [filterKey]: openid };
    if (status) filters.status = status;

    const allTasks = await getTable('navigation_tasks', {
      filters,
      order: 'created_at:desc',
      limit: String(limitNum),
      offset: String((pageNum - 1) * limitNum)
    });

    const tasks = Array.isArray(allTasks) ? allTasks : [];

    // 获取总数
    const countResult = await getTable('navigation_tasks', {
      filters,
      select: 'task_id'
    });
    const total = Array.isArray(countResult) ? countResult.length : 0;

    return success(res, {
      total,
      page: pageNum,
      limit: limitNum,
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
 */
router.get('/pending', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;

    const tasks = await getTable('navigation_tasks', {
      filters: {
        receiver_openid: openid,
        status: 'waiting'
      },
      order: 'created_at:desc'
    });

    const pendingTasks = Array.isArray(tasks) ? tasks : [];

    return success(res, {
      total: pendingTasks.length,
      tasks: pendingTasks
    });
  } catch (err) {
    console.error('获取待处理任务失败:', err);
    return error(res, '获取待处理任务失败', 'GET_PENDING_FAILED', 500);
  }
});

/**
 * GET /api/tasks/:taskId
 * 获取任务详情
 */
router.get('/:taskId', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const taskId = req.params.taskId;

    const task = await getTaskByTaskId(taskId);

    if (!task) {
      return notFound(res, '任务不存在');
    }

    // 验证权限
    if (task.sender_openid !== openid && task.receiver_openid !== openid) {
      return error(res, '无权查看此任务', 'PERMISSION_DENIED', 403);
    }

    // 解析 JSON 字段
    parseTaskJsonFields(task);

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

    const task = await getTaskByTaskId(taskId);

    if (!task) {
      return notFound(res, '任务不存在');
    }

    if (task.receiver_openid !== openid) {
      return error(res, '无权操作此任务', 'PERMISSION_DENIED', 403);
    }

    if (task.status !== 'waiting') {
      return error(res, `任务状态为 ${task.status}，无法接受`, 'INVALID_STATUS', 400);
    }

    await updateTable('navigation_tasks',
      { task_id: taskId },
      { status: 'accepted', accepted_at: new Date().toISOString().slice(0, 19).replace('T', ' ') }
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

    const task = await getTaskByTaskId(taskId);

    if (!task) {
      return notFound(res, '任务不存在');
    }

    if (task.receiver_openid !== openid) {
      return error(res, '无权操作此任务', 'PERMISSION_DENIED', 403);
    }

    if (task.status !== 'accepted') {
      return error(res, `任务状态为 ${task.status}，无法开始导航`, 'INVALID_STATUS', 400);
    }

    await updateTable('navigation_tasks',
      { task_id: taskId },
      { status: 'navigating', started_at: new Date().toISOString().slice(0, 19).replace('T', ' ') }
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

    const task = await getTaskByTaskId(taskId);

    if (!task) {
      return notFound(res, '任务不存在');
    }

    if (task.receiver_openid !== openid) {
      return error(res, '无权操作此任务', 'PERMISSION_DENIED', 403);
    }

    if (!['accepted', 'navigating'].includes(task.status)) {
      return error(res, `任务状态为 ${task.status}，无法完成`, 'INVALID_STATUS', 400);
    }

    await updateTable('navigation_tasks',
      { task_id: taskId },
      { status: 'finished', finished_at: new Date().toISOString().slice(0, 19).replace('T', ' ') }
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
 */
router.post('/:taskId/cancel', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const taskId = req.params.taskId;
    const { reason } = req.body;

    const task = await getTaskByTaskId(taskId);

    if (!task) {
      return notFound(res, '任务不存在');
    }

    if (task.sender_openid !== openid && task.receiver_openid !== openid) {
      return error(res, '无权操作此任务', 'PERMISSION_DENIED', 403);
    }

    const cancelledBy = task.sender_openid === openid ? 'sender' : 'receiver';

    if (!['waiting', 'accepted', 'navigating'].includes(task.status)) {
      return error(res, `任务状态为 ${task.status}，无法取消`, 'INVALID_STATUS', 400);
    }

    await updateTable('navigation_tasks',
      { task_id: taskId },
      {
        status: 'cancelled',
        cancelled_at: new Date().toISOString().slice(0, 19).replace('T', ' '),
        cancel_reason: reason || null,
        cancelled_by: cancelledBy
      }
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

    const task = await getTaskByTaskId(taskId);

    if (!task) {
      return notFound(res, '任务不存在');
    }

    if (task.sender_openid !== openid) {
      return error(res, '无权操作此任务', 'PERMISSION_DENIED', 403);
    }

    if (!['accepted', 'navigating'].includes(task.status)) {
      return error(res, `任务状态为 ${task.status}，无法更新路线`, 'INVALID_STATUS', 400);
    }

    await updateTable('navigation_tasks',
      { task_id: taskId },
      {
        route_data: typeof route_data === 'object' ? JSON.stringify(route_data) : route_data,
        route_summary: route_summary ? (typeof route_summary === 'object' ? JSON.stringify(route_summary) : route_summary) : null,
        distance_meters: distance_meters || null,
        duration_seconds: duration_seconds || null
      }
    );

    return success(res, { message: '路线已更新' });
  } catch (err) {
    console.error('更新路线失败:', err);
    return error(res, '更新路线失败', 'UPDATE_ROUTE_FAILED', 500);
  }
});

module.exports = router;
