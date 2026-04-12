/**
 * 实时位置管理路由
 *
 * 使用 CloudBase MySQL RESTful API
 * 路由列表：
 * POST   /api/locations/update             - 更新位置（接收者上传位置）
 * GET    /api/locations/:receiverOpenid    - 查询位置（发送者查看接收者位置）
 * POST   /api/locations/sharing/toggle     - 切换位置共享状态
 */

const express = require('express');
const router = express.Router();
const { getTable, insertTable, updateTable } = require('../lib/database');
const { success, validationError, error, notFound } = require('../lib/response');
const { authMiddleware } = require('../middleware/auth');

// ==========================================
// 路由定义
// ==========================================

/**
 * POST /api/locations/update
 * 更新位置信息（接收者上传实时位置）
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

    // 检查是否正在共享位置
    const locations = await getTable('real_time_locations', {
      filters: { receiver_openid: receiverOpenid }
    });

    const locationRecord = Array.isArray(locations) ? locations[0] : null;
    const isSharing = locationRecord && locationRecord.is_sharing === 1;

    // 如果未共享位置，则不更新（节省资源）
    if (!isSharing) {
      return success(res, {
        message: '位置未共享，未更新位置数据',
        is_sharing: false
      });
    }

    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');

    // 更新或插入位置（UPSERT）
    // RESTful API 不支持 ON DUPLICATE KEY UPDATE，先尝试更新，如果无记录则插入
    const updateResult = await updateTable('real_time_locations',
      { receiver_openid: receiverOpenid },
      {
        task_id: task_id || null,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy || null,
        speed: speed || null,
        bearing: bearing || null,
        altitude: altitude || null,
        is_navigating: is_navigating !== undefined ? (is_navigating ? 1 : 0) : 1,
        is_sharing: 1,
        updated_at: now
      }
    );

    // 如果更新无影响行数（记录不存在），创建新记录
    if (!updateResult || (Array.isArray(updateResult) && updateResult.length === 0)) {
      await insertTable('real_time_locations', {
        receiver_openid: receiverOpenid,
        task_id: task_id || null,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy || null,
        speed: speed || null,
        bearing: bearing || null,
        altitude: altitude || null,
        is_navigating: is_navigating !== undefined ? (is_navigating ? 1 : 0) : 1,
        is_sharing: 1,
        updated_at: now
      });
    }

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
    const bindings = await getTable('user_bindings', {
      filters: {
        sender_openid: senderOpenid,
        receiver_openid: receiverOpenid,
        status: 'active'
      }
    });

    if (!Array.isArray(bindings) || bindings.length === 0) {
      return error(res, '与该接收者没有绑定关系', 'NO_BINDING', 403);
    }

    // 查询位置
    const locations = await getTable('real_time_locations', {
      filters: {
        receiver_openid: receiverOpenid,
        is_sharing: 1
      }
    });

    if (!Array.isArray(locations) || locations.length === 0) {
      return notFound(res, '接收者未共享位置');
    }

    const location = locations[0];

    // 如果有任务信息，查询任务获取目的地
    let distance_to_destination = null;
    if (location.task_id) {
      const tasks = await getTable('navigation_tasks', {
        filters: { task_id: location.task_id }
      });
      const task = Array.isArray(tasks) ? tasks[0] : null;

      if (task && task.end_latitude && task.end_longitude && location.latitude && location.longitude) {
        // Haversine 公式计算距离
        const R = 6371000; // 地球半径（米）
        const dLat = (task.end_latitude - location.latitude) * Math.PI / 180;
        const dLon = (task.end_longitude - location.longitude) * Math.PI / 180;
        const a =
          Math.sin(dLat / 2) * Math.sin(dLat / 2) +
          Math.cos(location.latitude * Math.PI / 180) * Math.cos(task.end_latitude * Math.PI / 180) *
          Math.sin(dLon / 2) * Math.sin(dLon / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        distance_to_destination = Math.round(R * c);
      }
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
    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');

    // 尝试更新现有记录
    const existingLocations = await getTable('real_time_locations', {
      filters: { receiver_openid: receiverOpenid }
    });

    if (Array.isArray(existingLocations) && existingLocations.length > 0) {
      // 记录存在，更新状态
      await updateTable('real_time_locations',
        { receiver_openid: receiverOpenid },
        { is_sharing: sharingValue, updated_at: now }
      );
    } else if (is_sharing) {
      // 记录不存在且要开启共享，创建初始记录
      await insertTable('real_time_locations', {
        receiver_openid: receiverOpenid,
        latitude: 0,
        longitude: 0,
        is_navigating: 0,
        is_sharing: sharingValue,
        updated_at: now
      });
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
