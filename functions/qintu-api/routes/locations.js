/**
 * 实时位置管理路由
 * 
 * 路由列表：
 * POST   /api/locations/update      - 更新位置（接收者上传位置）
 * GET    /api/locations/:receiverOpenid  - 查询位置（发送者查看接收者位置）
 * POST   /api/locations/sharing/toggle   - 切换位置共享状态
 */

const express = require('express');
const router = express.Router();
const { query } = require('../lib/database');
const { success, validationError, error, notFound } = require('../lib/response');
const { authMiddleware } = require('../middleware/auth');

/**
 * POST /api/locations/update
 * 更新位置信息（接收者上传实时位置）
 * 
 * 需要认证（接收者角色）
 * 请求体：
 * {
 *   "task_id": "task_uuid",           // 可选，当前导航任务 ID
 *   "latitude": 39.9042,              // 必需
 *   "longitude": 116.4074,            // 必需
 *   "accuracy": 10.5,                 // 可选，定位精度（米）
 *   "speed": 45.5,                    // 可选，速度（km/h）
 *   "bearing": 180.0,                 // 可选，方向角（0-360度）
 *   "altitude": 50.0,                 // 可选，海拔（米）
 *   "is_navigating": true             // 可选，是否正在导航
 * }
 */
router.post('/update', authMiddleware, async (req, res) => {
  try {
    const receiverOpenid = req.user.openid;
    const {
      task_id,
      latitude,
      longitude,
      accuracy,
      speed,
      bearing,
      altitude,
      is_navigating
    } = req.body;

    // 验证接收者角色
    if (req.user.user_type === 'sender') {
      return error(res, '发送者角色无需上传位置', 'PERMISSION_DENIED', 403);
    }

    // 参数验证
    if (latitude === undefined || longitude === undefined) {
      return validationError(res, 'latitude 和 longitude 是必需参数');
    }

    // 验证坐标范围
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      return validationError(res, '经纬度坐标超出有效范围');
    }

    // 检查是否有进行中的任务
    let taskId = task_id;
    if (!taskId) {
      const tasks = await query(
        `SELECT task_id FROM navigation_tasks 
         WHERE receiver_openid = ? AND status IN ('accepted', 'navigating')
         ORDER BY created_at DESC LIMIT 1`,
        [receiverOpenid]
      );

      if (tasks.length > 0) {
        taskId = tasks[0].task_id;
      }
    }

    // 检查是否正在共享位置
    const locations = await query(
      'SELECT is_sharing FROM real_time_locations WHERE receiver_openid = ?',
      [receiverOpenid]
    );

    const isSharing = locations.length > 0 && locations[0].is_sharing === 1;

    // 如果未共享位置，则不更新（节省资源）
    if (!isSharing) {
      return success(res, {
        message: '位置未共享，未更新位置数据',
        is_sharing: false
      });
    }

    // 更新或插入位置（UPSERT）
    await query(
      `INSERT INTO real_time_locations (
        receiver_openid, task_id, latitude, longitude, 
        accuracy, speed, bearing, altitude, 
        is_navigating, is_sharing, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW())
      ON DUPLICATE KEY UPDATE
        task_id = VALUES(task_id),
        latitude = VALUES(latitude),
        longitude = VALUES(longitude),
        accuracy = VALUES(accuracy),
        speed = VALUES(speed),
        bearing = VALUES(bearing),
        altitude = VALUES(altitude),
        is_navigating = VALUES(is_navigating),
        updated_at = NOW()`,
      [
        receiverOpenid,
        taskId || null,
        latitude,
        longitude,
        accuracy || null,
        speed || null,
        bearing || null,
        altitude || null,
        is_navigating !== undefined ? (is_navigating ? 1 : 0) : 1
      ]
    );

    return success(res, {
      message: '位置已更新',
      is_sharing: true
    });
  } catch (err) {
    console.error('更新位置失败:', err);
    return error(res, '更新位置失败', 'UPDATE_LOCATION_FAILED', 500);
  }
});

/**
 * GET /api/locations/:receiverOpenid
 * 查询接收者的实时位置（发送者查看）
 * 
 * 需要认证（发送者角色）
 * 注意：只能查看已绑定接收者的位置
 */
router.get('/:receiverOpenid', authMiddleware, async (req, res) => {
  try {
    const senderOpenid = req.user.openid;
    const receiverOpenid = req.params.receiverOpenid;

    // 验证发送者角色
    if (req.user.user_type === 'receiver') {
      return error(res, '接收者角色无法查看位置', 'PERMISSION_DENIED', 403);
    }

    // 验证绑定关系
    const bindings = await query(
      `SELECT id FROM user_bindings 
       WHERE sender_openid = ? AND receiver_openid = ? AND status = 'active'`,
      [senderOpenid, receiverOpenid]
    );

    if (bindings.length === 0) {
      return error(res, '与该接收者没有绑定关系', 'NO_BINDING', 403);
    }

    // 查询位置
    const locations = await query(
      `SELECT rtl.*,
              nt.status as task_status,
              nt.end_name,
              nt.end_latitude,
              nt.end_longitude
       FROM real_time_locations rtl
       LEFT JOIN navigation_tasks nt ON rtl.task_id = nt.task_id
       WHERE rtl.receiver_openid = ? AND rtl.is_sharing = 1`,
      [receiverOpenid]
    );

    if (locations.length === 0) {
      return notFound(res, '接收者未共享位置');
    }

    const location = locations[0];

    // 计算与目的地的距离（简单直线距离）
    let distance_to_destination = null;
    if (location.latitude && location.longitude && location.end_latitude && location.end_longitude) {
      // Haversine 公式计算距离
      const R = 6371000; // 地球半径（米）
      const dLat = (location.end_latitude - location.latitude) * Math.PI / 180;
      const dLon = (location.end_longitude - location.longitude) * Math.PI / 180;
      const a = 
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(location.latitude * Math.PI / 180) * Math.cos(location.end_latitude * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      distance_to_destination = Math.round(R * c);
    }

    return success(res, {
      ...location,
      distance_to_destination
    });
  } catch (err) {
    console.error('查询位置失败:', err);
    return error(res, '查询位置失败', 'GET_LOCATION_FAILED', 500);
  }
});

/**
 * POST /api/locations/sharing/toggle
 * 切换位置共享状态
 * 
 * 需要认证（接收者角色）
 * 请求体：
 * {
 *   "is_sharing": true  // true=开始共享，false=停止共享
 * }
 */
router.post('/sharing/toggle', authMiddleware, async (req, res) => {
  try {
    const receiverOpenid = req.user.openid;
    const { is_sharing } = req.body;

    // 验证接收者角色
    if (req.user.user_type === 'sender') {
      return error(res, '发送者角色无法切换位置共享', 'PERMISSION_DENIED', 403);
    }

    if (is_sharing === undefined) {
      return validationError(res, 'is_sharing 是必需参数');
    }

    const sharingValue = is_sharing ? 1 : 0;

    // 更新共享状态
    await query(
      `UPDATE real_time_locations 
       SET is_sharing = ?, updated_at = NOW()
       WHERE receiver_openid = ?`,
      [sharingValue, receiverOpenid]
    );

    // 如果检查 affectedRows 为 0，说明记录不存在，创建新记录
    const result = await query(
      'SELECT ROW_COUNT() as affected'
    );

    if (result[0].affected === 0 && is_sharing) {
      // 创建初始位置记录
      await query(
        `INSERT INTO real_time_locations (
          receiver_openid, latitude, longitude, is_navigating, is_sharing, updated_at
        ) VALUES (?, 0, 0, 0, ?, NOW())`,
        [receiverOpenid, sharingValue]
      );
    }

    return success(res, {
      message: is_sharing ? '已开始共享位置' : '已停止共享位置',
      is_sharing: is_sharing
    });
  } catch (err) {
    console.error('切换位置共享失败:', err);
    return error(res, '切换位置共享失败', 'TOGGLE_SHARING_FAILED', 500);
  }
});

module.exports = router;
