/**
 * 位置管理路由 - 内存版本
 *
 * 被动共享模式：建立绑定关系后，接收者位置自动对发送者可见
 * 无需共享开关，无需审核确认
 *
 * 路由列表：
 * POST /api/locations/update              - 上传位置（接收者调用）
 * GET  /api/locations/:receiverOpenid    - 查询位置（发送者调用）
 * POST /api/locations/sharing/toggle     - 恒返回成功（兼容旧逻辑）
 */

const express = require('express');
const router = express.Router();
const { success, error, validationError, notFound } = require('../lib/response');
const { requireAuth } = require('../middleware/auth');

router.use(requireAuth);

// 初始化全局存储（兼容 serverless 冷启动）
global.userLocations = global.userLocations || {};

/**
 * POST /api/locations/update
 * 上传位置信息（接收者主动调用）
 * body: { latitude, longitude, accuracy, speed, bearing, altitude }
 */
router.post('/update', (req, res) => {
  try {
    const { latitude, longitude, accuracy, speed, bearing, altitude } = req.body;
    const openid = req.user.openid;

    // 参数验证
    if (latitude === undefined || longitude === undefined) {
      return validationError(res, 'latitude 和 longitude 是必需参数');
    }

    // 坐标范围验证
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      return validationError(res, '经纬度坐标超出有效范围');
    }

    // 存储到全局对象
    global.userLocations[openid] = {
      latitude,
      longitude,
      accuracy: accuracy || null,
      speed: speed || null,
      bearing: bearing || null,
      altitude: altitude || null,
      updatedAt: new Date().toISOString(),
    };

    if (process.env.NODE_ENV !== 'production') {
      console.log(`[Locations] 位置更新: ${openid} → lat=${latitude.toFixed(6)}, lng=${longitude.toFixed(6)}`);
    }

    return success(res, { message: '位置已更新' });
  } catch (err) {
    console.error('更新位置失败:', err);
    return error(res, '更新位置失败', 'UPDATE_LOCATION_FAILED', 500);
  }
});

/**
 * GET /api/locations/:receiverOpenid
 * 查询接收者的实时位置（发送者调用）
 * 无需共享开关，绑定关系即意味着可查询
 */
router.get('/:receiverOpenid', (req, res) => {
  try {
    const senderOpenid = req.user.openid;
    const receiverOpenid = req.params.receiverOpenid;

    if (process.env.NODE_ENV !== 'production') {
      console.log(`[Locations] 查询位置: sender=${senderOpenid}, receiver=${receiverOpenid}`);
    }

    // 验证绑定关系（sender 查询 receiver）
    const bindings = global.mockBindings;
    if (!bindings) {
      return error(res, '绑定数据不可用', 'BINDING_NOT_FOUND', 500);
    }

    let hasActiveBinding = false;
    bindings.forEach(binding => {
      if (
        binding.sender_openid === senderOpenid &&
        binding.receiver_openid === receiverOpenid &&
        binding.status === 'active'
      ) {
        hasActiveBinding = true;
      }
      // 双向查询：receiver 也可以查询 sender 的位置
      if (
        binding.sender_openid === receiverOpenid &&
        binding.receiver_openid === senderOpenid &&
        binding.status === 'active'
      ) {
        hasActiveBinding = true;
      }
    });

    if (!hasActiveBinding) {
      return error(res, '与该用户没有绑定关系', 'NO_BINDING', 403);
    }

    // 查询位置
    const location = global.userLocations[receiverOpenid];
    if (!location) {
      return notFound(res, '该用户暂无位置信息');
    }

    return success(res, {
      receiver_openid: receiverOpenid,
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      speed: location.speed,
      bearing: location.bearing,
      altitude: location.altitude,
      updated_at: location.updatedAt,
    });
  } catch (err) {
    console.error('查询位置失败:', err);
    return error(res, '查询位置失败', 'GET_LOCATION_FAILED', 500);
  }
});

/**
 * POST /api/locations/sharing/toggle
 * 共享开关（兼容旧逻辑，恒返回成功）
 * 被动共享模式下不需要开关
 */
router.post('/sharing/toggle', (req, res) => {
  // 被动共享模式：无需开关，直接返回成功
  return success(res, {
    message: '位置共享已开启',
    is_sharing: true
  });
});

module.exports = router;
