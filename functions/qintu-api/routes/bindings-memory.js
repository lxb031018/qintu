/**
 * 绑定关系管理路由 - 内存版本
 * 
 * 使用内存存储，适合开发和测试
 * 重启云函数后数据会丢失
 */

const express = require('express');
const router = express.Router();
const { success, validationError, error, notFound } = require('../lib/response');
const { requireAuth } = require('../middleware/auth');
const { logOperation } = require('../lib/operation_logger');
const config = require('../config');
const { normalizePhone, isValidChinesePhone, maskPhone } = require('../lib/utils/phone');

// 🌟 应用中间件
router.use(requireAuth);

// 内存存储
const mockBindings = new Map();
let bindingIdCounter = 1;

// 绑定限制
const BINDING_LIMITS = config.LIMITS;

// 🌟 是否开发环境（控制调试日志）
const isDev = process.env.NODE_ENV !== 'production';

/**
 * GET /api/bindings/my
 * 获取我的所有绑定关系
 */
router.get('/my', (req, res) => {
  try {
    const openid = req.user.openid;
    
    const bindings = [];
    mockBindings.forEach((binding, id) => {
      if (binding.status === 'active' && 
          (binding.sender_openid === openid || binding.receiver_openid === openid)) {
        const isSender = binding.sender_openid === openid;
        bindings.push({
          id: parseInt(id),
          status: binding.status,
          remark: binding.remark,
          created_at: binding.created_at,
          updated_at: binding.updated_at,
          my_role: isSender ? 'sender' : 'receiver',
          partner_openid: isSender ? binding.receiver_openid : binding.sender_openid,
          partner_nickname: isSender ? binding.receiver_nickname : binding.sender_nickname,
          partner_phone: isSender ? binding.receiver_phone : binding.sender_phone,
          partner_type: isSender ? binding.receiver_type : binding.sender_type,
          sender_openid: binding.sender_openid,
          receiver_openid: binding.receiver_openid
        });
      }
    });

    const asSender = bindings.filter(b => b.my_role === 'sender').length;
    const asReceiver = bindings.filter(b => b.my_role === 'receiver').length;

    return success(res, {
      total: bindings.length,
      as_sender: asSender,
      as_receiver: asReceiver,
      bindings: bindings
    });
  } catch (err) {
    console.error('获取绑定关系失败:', err);
    return error(res, '获取绑定关系失败', 'GET_BINDINGS_FAILED', 500);
  }
});

/**
 * GET /api/bindings/pending
 * 获取待确认的绑定请求
 */
router.get('/pending', (req, res) => {
  try {
    const openid = req.user.openid;

    if (openid === 'unknown_user') {
       return success(res, []);
    }

    // 清理超过 30 天的过期记录和被拒绝的记录
    const keysToDelete = [];
    mockBindings.forEach((binding, key) => {
      if ((binding.status === 'expired' || binding.status === 'revoked') && binding.expired_at) {
        const expiredAt = new Date(binding.expired_at);
        const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
        if (expiredAt < thirtyDaysAgo) {
          keysToDelete.push(key);
        }
      }
    });
    keysToDelete.forEach(key => mockBindings.delete(key));

    const pendingRequests = [];
    mockBindings.forEach((binding, id) => {
      if (binding.status === 'pending' && binding.receiver_openid === openid) {
        // 检查是否过期
        const expiredAt = new Date(binding.expired_at);
        if (expiredAt < new Date()) {
          binding.status = 'expired';
          return;
        }

        pendingRequests.push({
          id: parseInt(id),
          sender_name: binding.sender_nickname,            // 🌟 "对方对您的称呼"（如"老妈"）
          sender_nickname: binding.sender_nickname,       // 🌟 同上
          sender_phone: binding.sender_phone ?
            binding.sender_phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2') : '未知',
          created_at: binding.created_at,
          expired_at: binding.expired_at,
        });
      }
    });

    return success(res, pendingRequests);
  } catch (err) {
    console.error('获取待确认请求失败:', err);
    return error(res, '获取失败', 'GET_PENDING_FAILED', 500);
  }
});

/**
 * GET /api/bindings/sent
 * 获取我发出的绑定请求（包括 pending/rejected/expired 状态）
 */
router.get('/sent', (req, res) => {
  try {
    const openid = req.user.openid;

    if (openid === 'unknown_user') {
       return success(res, []);
    }

    // 清理超过 30 天的过期记录和被拒绝的记录
    const keysToDelete = [];
    mockBindings.forEach((binding, key) => {
      if ((binding.status === 'expired' || binding.status === 'revoked') && binding.expired_at) {
        const expiredAt = new Date(binding.expired_at);
        const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
        if (expiredAt < thirtyDaysAgo) {
          keysToDelete.push(key);
        }
      }
    });
    keysToDelete.forEach(key => mockBindings.delete(key));

    const sentRequests = [];
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    mockBindings.forEach((binding, id) => {
      // 查询所有状态的请求（pending/rejected/expired/active），最近 7 天的
      if (binding.sender_openid === openid) {
        const createdAt = new Date(binding.created_at);
        if (createdAt < sevenDaysAgo) {
          return; // 跳过 7 天前的请求
        }

        // 检查是否过期（将已过期的 pending 请求标记为 expired）
        if (binding.status === 'pending' && binding.expired_at) {
          const expiredAt = new Date(binding.expired_at);
          if (expiredAt < new Date()) {
            binding.status = 'expired';
          }
        }

        sentRequests.push({
          id: parseInt(id),
          status: binding.status,
          receiver_name: binding.receiver_nickname || binding.remark, // 🌟 显示发送者填写的"您对对方的称呼"
          created_at: binding.created_at,
          expired_at: binding.expired_at,
          receiver_nickname: binding.receiver_nickname,
          receiver_phone: binding.receiver_phone ?
            binding.receiver_phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2') : '未知'
        });
      }
    });

    if (isDev) {
      console.log(`[DEBUG /sent] 返回数据:`, JSON.stringify(sentRequests.map(r => ({
        receiver_nickname: r.receiver_nickname,
        receiver_phone: r.receiver_phone
      })), null, 2));
    }

    return success(res, sentRequests);
  } catch (err) {
    console.error('获取已发出请求失败:', err);
    return error(res, '获取失败', 'GET_SENT_FAILED', 500);
  }
});

/**
 * POST /api/bindings/request-phone
 * 发送者通过手机号请求绑定
 */
router.post('/request-phone', (req, res) => {
  try {
    const senderOpenid = req.user.openid; // 🌟 直接从中间件获取
    const { receiver_phone, sender_name, receiver_name } = req.body;

    if (!receiver_phone) {
      return validationError(res, 'receiver_phone 是必填参数');
    }

    if (!senderOpenid) {
      return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
    }

    if (isDev) console.log(`[Bindings] 发送绑定请求: sender=${senderOpenid}, receiver_phone=${maskPhone(receiver_phone)}`);

    // 🌟 核心逻辑：查电话本，找到对方真实的 OpenID
    const cleanPhone = normalizePhone(receiver_phone);

    if (!isValidChinesePhone(cleanPhone)) {
      if (isDev) console.error(`[Bindings] ❌ 手机号格式不正确: "${cleanPhone}"`);
      return error(res, '手机号格式不正确（应为 11 位中国手机号）', 'INVALID_PHONE', 400);
    }

    // 🌟 反向查找发送者的手机号
    const userMap = global.userPhoneMap || {};
    let senderPhone = null;
    Object.entries(userMap).forEach(([phone, openid]) => {
      if (openid === senderOpenid) senderPhone = phone;
    });

    const receiverOpenid = userMap[cleanPhone];

    // 如果电话本里没有这个人，说明未注册
    if (!receiverOpenid) {
      return error(res, '该手机号尚未注册亲途', 'USER_NOT_FOUND', 404);
    }

    // 检查是否绑定自己
    if (senderOpenid === receiverOpenid) {
      return error(res, '不能绑定自己', 'SELF_BINDING', 400);
    }

    // 检查绑定限制（统一上限）
    let senderActiveCount = 0;
    let receiverActiveCount = 0;
    mockBindings.forEach(binding => {
      if (binding.sender_openid === senderOpenid && binding.status === 'active') senderActiveCount++;
      if (binding.receiver_openid === receiverOpenid &&
          (binding.status === 'active' || binding.status === 'pending')) receiverActiveCount++;
    });

    if (senderActiveCount >= BINDING_LIMITS.MAX_BINDINGS_PER_USER) {
      return error(res, '您的绑定人数已达上限', 'BINDING_LIMIT_EXCEEDED', 409);
    }

    if (receiverActiveCount >= BINDING_LIMITS.MAX_BINDINGS_PER_USER) {
      return error(res, '对方绑定人数已达上限', 'RECEIVER_BINDING_FULL', 409);
    }

    // 检查是否已存在绑定
    let existingBinding = null;
    mockBindings.forEach(binding => {
      if (binding.sender_openid === senderOpenid && binding.receiver_openid === receiverOpenid) {
        if (binding.status === 'active' || binding.status === 'pending') {
          existingBinding = binding;
        }
      }
    });

    if (existingBinding) {
      if (existingBinding.status === 'active') {
        return error(res, '与该用户的绑定关系已生效', 'BINDING_EXISTS', 409);
      }
      if (existingBinding.status === 'pending') {
        return error(res, '已发送过绑定请求，请等待对方确认', 'PENDING_EXISTS', 409);
      }
    }

    // 创建 pending 绑定
    const bindingId = bindingIdCounter++;
    const now = new Date().toISOString();
    const expiredAt = new Date(Date.now() + config.BINDING.EXPIRES_MS).toISOString(); // 🌟 使用配置中的过期时间

    const newBinding = {
      id: bindingId,
      sender_openid: senderOpenid,
      receiver_openid: receiverOpenid,
      sender_nickname: sender_name || '发送者',       // 接收者看到的发送者称呼
      receiver_nickname: receiver_name || '接收者',   // 发送者看到的接收者称呼
      receiver_phone: cleanPhone,                      // 接收者的手机号（发送者看到）
      sender_phone: senderPhone,                       // 发送者的手机号（接收者看到）
      status: 'pending',
      remark: receiver_name || '未命名接收者',         // 发送者看到的接收者称呼（同 receiver_nickname）
      created_at: now,
      updated_at: now,
      expired_at: expiredAt
    };

    mockBindings.set(bindingId.toString(), newBinding);

    if (isDev) console.log(`[Bindings] 绑定请求创建成功: id=${bindingId}, sender=${senderOpenid}, receiver=${receiverOpenid}`);

    // 🌟 记录操作日志
    logOperation({
      userOpenid: senderOpenid,
      action: 'REQUEST_BINDING',
      targetType: 'binding',
      targetId: String(bindingId),
      details: { receiver_openid: receiverOpenid, sender_name: sender_name || '未命名发送者' },
      ipAddress: req.ip
    }).catch(() => {}); // 日志失败不影响主流程

    return success(res, {
      message: '绑定请求已发送',
      binding_id: bindingId
    }, 201);

  } catch (err) {
    console.error('发送绑定请求失败:', err);
    console.error('错误堆栈:', err.stack);
    return error(res, '请求失败: ' + err.message, 'REQUEST_BINDING_FAILED', 500);
  }
});

/**
 * POST /api/bindings/confirm-request
 * 接收者确认绑定
 */
router.post('/confirm-request', (req, res) => {
  try {
    const receiverOpenid = req.user.openid; // 🌟 直接从中间件获取
    const { request_id } = req.body;
    if (!request_id) return validationError(res, 'request_id 是必填参数');

    if (isDev) console.log(`[Bindings] 尝试确认绑定: id=${request_id}, receiver=${receiverOpenid}`);

    const binding = mockBindings.get(request_id.toString());
    if (!binding || binding.receiver_openid !== receiverOpenid || binding.status !== 'pending') {
      return error(res, '请求不存在或状态异常', 'REQUEST_INVALID', 404);
    }

    // 更新状态为 active
    binding.status = 'active';
    binding.updated_at = new Date().toISOString();

    if (isDev) console.log(`[Bindings] ✅ 绑定确认成功: id=${request_id}`);

    // 🌟 记录操作日志
    logOperation({
      userOpenid: receiverOpenid,
      action: 'CONFIRM_BINDING',
      targetType: 'binding',
      targetId: String(request_id),
      details: { sender_openid: binding.sender_openid },
      ipAddress: req.ip
    }).catch(() => {});

    return success(res, { message: '绑定成功' });
  } catch (err) {
    console.error('确认绑定失败:', err);
    return error(res, '确认失败', 'CONFIRM_REQUEST_FAILED', 500);
  }
});

/**
 * POST /api/bindings/reject-request
 * 接收者拒绝绑定
 */
router.post('/reject-request', (req, res) => {
  try {
    const receiverOpenid = req.user.openid; // 🌟 直接从中间件获取
    const { request_id } = req.body;
    if (!request_id) return validationError(res, 'request_id 是必填参数');

    if (isDev) console.log(`[Bindings] 尝试拒绝绑定: id=${request_id}, receiver=${receiverOpenid}`);

    const binding = mockBindings.get(request_id.toString());
    if (!binding || binding.receiver_openid !== receiverOpenid || binding.status !== 'pending') {
      return error(res, '请求不存在', 'REQUEST_INVALID', 404);
    }

    binding.status = 'revoked';
    binding.updated_at = new Date().toISOString();

    if (isDev) console.log(`[Bindings] ❌ 绑定已拒绝: id=${request_id}`);

    // 🌟 记录操作日志
    logOperation({
      userOpenid: receiverOpenid,
      action: 'REJECT_BINDING',
      targetType: 'binding',
      targetId: String(request_id),
      details: { sender_openid: binding.sender_openid },
      ipAddress: req.ip
    }).catch(() => {});

    return success(res, { message: '已拒绝' });
  } catch (err) {
    console.error('拒绝绑定失败:', err);
    return error(res, '拒绝失败', 'REJECT_REQUEST_FAILED', 500);
  }
});

/**
 * DELETE /api/bindings/:id
 * 解除绑定关系 / 取消发出的请求
 */
router.delete('/:id', (req, res) => {
  try {
    const openid = req.user.openid; // 🌟 直接从中间件获取
    const bindingId = req.params.id;

    if (isDev) console.log(`[Bindings] 尝试解除绑定: id=${bindingId}, user=${openid}`);

    const binding = mockBindings.get(bindingId);
    if (!binding) {
      return notFound(res, '绑定关系不存在');
    }

    if (binding.sender_openid !== openid && binding.receiver_openid !== openid) {
      return error(res, '无权操作此绑定关系', 'PERMISSION_DENIED', 403);
    }

    // pending 状态（发送者取消请求）：直接删除记录，不留下任何痕迹
    if (binding.status === 'pending') {
      mockBindings.delete(bindingId);
      if (isDev) console.log(`[Bindings] ✅ 请求已取消并删除: id=${bindingId}`);

      // 🌟 记录操作日志
      logOperation({
        userOpenid: openid,
        action: 'CANCEL_BINDING_REQUEST',
        targetType: 'binding',
        targetId: String(bindingId),
        details: { receiver_openid: binding.receiver_openid },
        ipAddress: req.ip
      }).catch(() => {});

      return success(res, { message: '绑定请求已取消' });
    }

    // 其他状态（active/revoked/expired）：更新状态为已撤销
    binding.status = 'revoked';
    binding.updated_at = new Date().toISOString();

    if (isDev) console.log(`[Bindings] ✅ 绑定已解除: id=${bindingId}`);

    // 🌟 记录操作日志
    logOperation({
      userOpenid: openid,
      action: 'REVOKE_BINDING',
      targetType: 'binding',
      targetId: String(bindingId),
      details: {
        role: binding.sender_openid === openid ? 'sender' : 'receiver',
        partner_openid: binding.sender_openid === openid ? binding.receiver_openid : binding.sender_openid
      },
      ipAddress: req.ip
    }).catch(() => {});

    return success(res, { message: '绑定关系已解除' });
  } catch (err) {
    console.error('解除绑定失败:', err);
    return error(res, '解除绑定失败', 'REVOKE_BINDING_FAILED', 500);
  }
});

module.exports = router;
