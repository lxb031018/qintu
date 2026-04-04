/**
 * 绑定关系管理路由
 * 
 * 路由列表：
 * POST   /api/bindings/generate       - 生成绑定码（发送者）
 * POST   /api/bindings/confirm        - 确认绑定（接收者输入绑定码）
 * GET    /api/bindings/my             - 获取我的所有绑定关系
 * DELETE /api/bindings/:id            - 解除绑定关系
 * GET    /api/bindings/check/:code    - 检查绑定码是否有效
 */

const express = require('express');
const router = express.Router();
const { query, transaction } = require('../lib/database');
const { success, validationError, error, notFound } = require('../lib/response');
const { authMiddleware } = require('../middleware/auth');

/**
 * 生成 8 位随机绑定码
 * @returns {string} 绑定码（大写字母+数字）
 */
function generateBindCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 排除易混淆字符
  let code = '';
  for (let i = 0; i < 8; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

/**
 * 绑定关系常量
 */
const BINDING_LIMITS = {
  MAX_RECEIVERS_PER_SENDER: 5,   // 一个发送者最多绑定 5 个接收者（家庭场景）
  MAX_SENDERS_PER_RECEIVER: 3    // 一个接收者最多被 3 个发送者绑定（避免过度监护）
};

/**
 * POST /api/bindings/generate
 * 生成绑定码（发送者操作）
 * 
 * 需要认证
 * 请求体：
 * {
 *   "receiver_phone": "+86 13800138000",  // 可选，接收者手机号
 *   "remark": "给父亲的绑定"                // 可选，备注
 * }
 * 
 * 返回：
 * {
 *   "bind_code": "ABC12345",
 *   "expires_at": "2026-04-05T10:00:00Z"
 * }
 */
router.post('/generate', authMiddleware, async (req, res) => {
  try {
    const senderOpenid = req.user.openid;
    const { receiver_phone, remark } = req.body;

    // 验证发送者角色
    if (req.user.user_type === 'receiver') {
      return error(res, '接收者角色无法生成绑定码', 'PERMISSION_DENIED', 403);
    }

    // 检查发送者当前绑定数量
    const senderBindingsCount = await query(
      `SELECT COUNT(*) as count FROM user_bindings 
       WHERE sender_openid = ? AND status = 'active'`,
      [senderOpenid]
    );

    if (senderBindingsCount[0].count >= BINDING_LIMITS.MAX_RECEIVERS_PER_SENDER) {
      return error(
        res, 
        `绑定人数已达上限（最多${BINDING_LIMITS.MAX_RECEIVERS_PER_SENDER}个接收者）`, 
        'BINDING_LIMIT_EXCEEDED', 
        409
      );
    }

    // 如果提供了接收者手机号，查找对应的 openid
    let receiverOpenid = null;
    if (receiver_phone) {
      const users = await query(
        'SELECT openid FROM users WHERE phone = ? AND status = "active"',
        [receiver_phone]
      );
      
      if (users.length > 0) {
        receiverOpenid = users[0].openid;
        
        // 检查接收者被绑定数量
        const receiverBindingsCount = await query(
          `SELECT COUNT(*) as count FROM user_bindings 
           WHERE receiver_openid = ? AND status = 'active'`,
          [receiverOpenid]
        );

        if (receiverBindingsCount[0].count >= BINDING_LIMITS.MAX_SENDERS_PER_RECEIVER) {
          return error(
            res, 
            `该用户已被 ${BINDING_LIMITS.MAX_SENDERS_PER_RECEIVER} 个发送者绑定，无法继续绑定`, 
            'RECEIVER_BINDING_FULL', 
            409
          );
        }

        // 检查是否已存在绑定关系
        const existingBindings = await query(
          `SELECT id, status FROM user_bindings 
           WHERE sender_openid = ? AND receiver_openid = ?`,
          [senderOpenid, receiverOpenid]
        );

        if (existingBindings.length > 0) {
          const binding = existingBindings[0];
          if (binding.status === 'active') {
            return error(res, '与该用户的绑定关系已存在', 'BINDING_EXISTS', 409);
          }
        }
      }
    }

    // 生成唯一绑定码
    let bindCode;
    let isUnique = false;
    let attempts = 0;

    while (!isUnique && attempts < 10) {
      bindCode = generateBindCode();
      
      const existingCodes = await query(
        'SELECT id FROM user_bindings WHERE bind_code = ?',
        [bindCode]
      );

      if (existingCodes.length === 0) {
        isUnique = true;
      }
      attempts++;
    }

    if (!isUnique) {
      return error(res, '生成绑定码失败，请稍后重试', 'GENERATE_CODE_FAILED', 500);
    }

    // 如果已有接收者 openid，直接创建绑定关系
    if (receiverOpenid) {
      await query(
        `INSERT INTO user_bindings (sender_openid, receiver_openid, bind_code, status, remark, created_at)
         VALUES (?, ?, ?, 'active', ?, NOW())`,
        [senderOpenid, receiverOpenid, bindCode, remark || null]
      );

      // 返回绑定信息
      const result = await query(
        `SELECT b.id, b.bind_code, b.status, b.remark, 
                b.created_at, b.expired_at,
                u.openid as receiver_openid, u.nickname as receiver_nickname
         FROM user_bindings b
         LEFT JOIN users u ON b.receiver_openid = u.openid
         WHERE b.bind_code = ?`,
        [bindCode]
      );

      return success(res, {
        bind_code: bindCode,
        binding: result[0],
        message: '绑定关系已创建'
      }, 201);
    } else {
      // 返回绑定码，等待接收者确认
      const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24小时过期

      return success(res, {
        bind_code: bindCode,
        expires_at: expiresAt,
        message: '请将此绑定码告知接收者，接收者输入后即可建立绑定关系'
      }, 201);
    }
  } catch (err) {
    console.error('生成绑定码失败:', err);
    return error(res, '生成绑定码失败', 'GENERATE_CODE_FAILED', 500);
  }
});

/**
 * POST /api/bindings/confirm
 * 确认绑定（接收者输入绑定码）
 * 
 * 需要认证
 * 请求体：
 * {
 *   "bind_code": "ABC12345"
 * }
 */
router.post('/confirm', authMiddleware, async (req, res) => {
  try {
    const receiverOpenid = req.user.openid;
    const { bind_code } = req.body;

    // 参数验证
    if (!bind_code) {
      return validationError(res, 'bind_code 是必填参数');
    }

    // 验证接收者角色
    if (req.user.user_type === 'sender') {
      return error(res, '发送者角色无法确认绑定', 'PERMISSION_DENIED', 403);
    }

    // 检查接收者当前绑定数量
    const receiverBindingsCount = await query(
      `SELECT COUNT(*) as count FROM user_bindings 
       WHERE receiver_openid = ? AND status = 'active'`,
      [receiverOpenid]
    );

    if (receiverBindingsCount[0].count >= BINDING_LIMITS.MAX_SENDERS_PER_RECEIVER) {
      return error(
        res, 
        `绑定人数已达上限（最多${BINDING_LIMITS.MAX_SENDERS_PER_RECEIVER}个发送者）`, 
        'BINDING_LIMIT_EXCEEDED', 
        409
      );
    }

    // 查找绑定码
    const bindings = await query(
      `SELECT b.id, b.sender_openid, b.status, b.expired_at,
              u.openid, u.status as user_status
       FROM user_bindings b
       INNER JOIN users u ON b.sender_openid = u.openid
       WHERE b.bind_code = ?`,
      [bind_code.toUpperCase()]
    );

    if (bindings.length === 0) {
      return error(res, '绑定码无效', 'INVALID_CODE', 404);
    }

    const binding = bindings[0];

    // 检查绑定状态
    if (binding.status === 'active') {
      return error(res, '此绑定码已被使用', 'CODE_USED', 409);
    }

    if (binding.status === 'expired' || 
        (binding.expired_at && new Date(binding.expired_at) < new Date())) {
      return error(res, '绑定码已过期', 'CODE_EXPIRED', 400);
    }

    // 检查发送者状态
    if (binding.user_status === 'disabled') {
      return error(res, '发送者账号已被禁用', 'SENDER_DISABLED', 403);
    }

    // 检查发送者绑定数量
    const senderBindingsCount = await query(
      `SELECT COUNT(*) as count FROM user_bindings 
       WHERE sender_openid = ? AND status = 'active'`,
      [binding.sender_openid]
    );

    if (senderBindingsCount[0].count >= BINDING_LIMITS.MAX_RECEIVERS_PER_SENDER) {
      return error(
        res, 
        `该发送者绑定人数已达上限（最多${BINDING_LIMITS.MAX_RECEIVERS_PER_SENDER}个）`, 
        'SENDER_BINDING_FULL', 
        409
      );
    }

    // 检查是否已存在其他绑定关系
    const existingBindings = await query(
      `SELECT id, status FROM user_bindings 
       WHERE sender_openid = ? AND receiver_openid = ?`,
      [binding.sender_openid, receiverOpenid]
    );

    if (existingBindings.length > 0 && existingBindings[0].status === 'active') {
      return error(res, '与该发送者的绑定关系已存在', 'BINDING_EXISTS', 409);
    }

    // 更新绑定关系（设置接收者并激活）
    await query(
      `UPDATE user_bindings 
       SET receiver_openid = ?, status = 'active', updated_at = NOW()
       WHERE bind_code = ?`,
      [receiverOpenid, bind_code.toUpperCase()]
    );

    // 返回绑定信息
    const result = await query(
      `SELECT b.id, b.bind_code, b.status, b.remark, 
              b.created_at,
              s.openid as sender_openid, s.nickname as sender_nickname, s.phone as sender_phone
       FROM user_bindings b
       INNER JOIN users s ON b.sender_openid = s.openid
       WHERE b.bind_code = ?`,
      [bind_code.toUpperCase()]
    );

    return success(res, {
      message: '绑定关系已确认',
      binding: result[0]
    });
  } catch (err) {
    console.error('确认绑定失败:', err);
    return error(res, '确认绑定失败', 'CONFIRM_BINDING_FAILED', 500);
  }
});

/**
 * GET /api/bindings/my
 * 获取我的所有绑定关系
 * 
 * 需要认证
 * 返回：作为发送者的绑定 + 作为接收者的绑定
 */
router.get('/my', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;

    // 查询作为发送者的绑定
    const senderBindings = await query(
      `SELECT b.id, b.bind_code, b.status, b.remark, b.created_at,
              'sender' as my_role,
              r.openid as partner_openid, r.nickname as partner_nickname, 
              r.phone as partner_phone, r.user_type as partner_type
       FROM user_bindings b
       INNER JOIN users r ON b.receiver_openid = r.openid
       WHERE b.sender_openid = ? AND b.status = 'active'
       ORDER BY b.created_at DESC`,
      [openid]
    );

    // 查询作为接收者的绑定
    const receiverBindings = await query(
      `SELECT b.id, b.bind_code, b.status, b.remark, b.created_at,
              'receiver' as my_role,
              s.openid as partner_openid, s.nickname as partner_nickname, 
              s.phone as partner_phone, s.user_type as partner_type
       FROM user_bindings b
       INNER JOIN users s ON b.sender_openid = s.openid
       WHERE b.receiver_openid = ? AND b.status = 'active'
       ORDER BY b.created_at DESC`,
      [openid]
    );

    // 合并结果
    const allBindings = [...senderBindings, ...receiverBindings];

    return success(res, {
      total: allBindings.length,
      as_sender: senderBindings.length,
      as_receiver: receiverBindings.length,
      bindings: allBindings
    });
  } catch (err) {
    console.error('获取绑定关系失败:', err);
    return error(res, '获取绑定关系失败', 'GET_BINDINGS_FAILED', 500);
  }
});

/**
 * DELETE /api/bindings/:id
 * 解除绑定关系
 * 
 * 需要认证
 */
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const bindingId = parseInt(req.params.id);

    // 查找绑定关系
    const bindings = await query(
      `SELECT id, sender_openid, receiver_openid, status 
       FROM user_bindings WHERE id = ?`,
      [bindingId]
    );

    if (bindings.length === 0) {
      return notFound(res, '绑定关系不存在');
    }

    const binding = bindings[0];

    // 验证权限（只有绑定双方可以解绑）
    if (binding.sender_openid !== openid && binding.receiver_openid !== openid) {
      return error(res, '无权操作此绑定关系', 'PERMISSION_DENIED', 403);
    }

    // 更新状态为已撤销
    await query(
      `UPDATE user_bindings 
       SET status = 'revoked', updated_at = NOW()
       WHERE id = ?`,
      [bindingId]
    );

    return success(res, { message: '绑定关系已解除' });
  } catch (err) {
    console.error('解除绑定失败:', err);
    return error(res, '解除绑定失败', 'REVOKE_BINDING_FAILED', 500);
  }
});

/**
 * GET /api/bindings/check/:code
 * 检查绑定码是否有效（未绑定时预览）
 * 
 * 需要认证
 */
router.get('/check/:code', authMiddleware, async (req, res) => {
  try {
    const bindCode = req.params.code.toUpperCase();

    const bindings = await query(
      `SELECT b.status, b.expired_at,
              s.openid as sender_openid, s.nickname as sender_nickname
       FROM user_bindings b
       INNER JOIN users s ON b.sender_openid = s.openid
       WHERE b.bind_code = ?`,
      [bindCode]
    );

    if (bindings.length === 0) {
      return error(res, '绑定码无效', 'INVALID_CODE', 404);
    }

    const binding = bindings[0];
    const isExpired = binding.expired_at && new Date(binding.expired_at) < new Date();

    return success(res, {
      valid: binding.status !== 'active' && !isExpired,
      status: isExpired ? 'expired' : binding.status,
      sender_nickname: binding.sender_nickname
    });
  } catch (err) {
    console.error('检查绑定码失败:', err);
    return error(res, '检查绑定码失败', 'CHECK_CODE_FAILED', 500);
  }
});

/**
 * POST /api/bindings/request-phone
 * 发送者通过手机号请求绑定
 *
 * 请求体：
 * {
 *   "receiver_phone": "+86 13800138000",
 *   "sender_name": "张三"
 * }
 */
router.post('/request-phone', authMiddleware, async (req, res) => {
  try {
    const senderOpenid = req.user.openid;
    const { receiver_phone, sender_name } = req.body;

    if (!receiver_phone) {
      return validationError(res, 'receiver_phone 是必填参数');
    }

    // 1. 查找接收者 openid
    const users = await query(
      'SELECT openid, nickname FROM users WHERE phone LIKE ?',
      [`%${receiver_phone.replace('+86', '').trim()}`]
    );

    if (users.length === 0) {
      return error(res, '该手机号未注册亲途', 'USER_NOT_FOUND', 404);
    }

    const receiverOpenid = users[0].openid;

    if (senderOpenid === receiverOpenid) {
      return error(res, '不能绑定自己', 'SELF_BINDING', 400);
    }

    // 2. 检查绑定限制
    const senderBindingsCount = await query(
      `SELECT COUNT(*) as count FROM user_bindings WHERE sender_openid = ? AND status = 'active'`,
      [senderOpenid]
    );
    if (senderBindingsCount[0].count >= BINDING_LIMITS.MAX_RECEIVERS_PER_SENDER) {
      return error(res, '发送者绑定人数已达上限', 'BINDING_LIMIT_EXCEEDED', 409);
    }

    const receiverBindingsCount = await query(
      `SELECT COUNT(*) as count FROM user_bindings WHERE receiver_openid = ? AND status IN ('active', 'pending')`,
      [receiverOpenid]
    );
    if (receiverBindingsCount[0].count >= BINDING_LIMITS.MAX_SENDERS_PER_RECEIVER) {
      return error(res, '该接收者已被过多发送者绑定', 'RECEIVER_BINDING_FULL', 409);
    }

    // 3. 检查是否已存在
    const existingBindings = await query(
      `SELECT id, status FROM user_bindings WHERE sender_openid = ? AND receiver_openid = ?`,
      [senderOpenid, receiverOpenid]
    );

    if (existingBindings.length > 0) {
      const status = existingBindings[0].status;
      if (status === 'active') return error(res, '与该用户的绑定关系已生效', 'BINDING_EXISTS', 409);
      if (status === 'pending') return error(res, '已发送过绑定请求，请等待对方确认', 'PENDING_EXISTS', 409);
    }

    // 4. 创建 pending 记录 (使用 remark 暂存 sender_name)
    await query(
      `INSERT INTO user_bindings (sender_openid, receiver_openid, status, remark, created_at)
       VALUES (?, ?, 'pending', ?, NOW())`,
      [senderOpenid, receiverOpenid, sender_name || '未命名发送者']
    );

    return success(res, { message: '绑定请求已发送' }, 201);

  } catch (err) {
    console.error('发送绑定请求失败:', err);
    return error(res, '请求失败', 'REQUEST_BINDING_FAILED', 500);
  }
});

/**
 * GET /api/bindings/pending
 * 获取接收者待确认的绑定请求
 */
router.get('/pending', authMiddleware, async (req, res) => {
  try {
    const receiverOpenid = req.user.openid;

    const requests = await query(
      `SELECT b.id, b.remark as sender_name, b.created_at,
              u.nickname as sender_nickname, u.phone as sender_phone
       FROM user_bindings b
       JOIN users u ON b.sender_openid = u.openid
       WHERE b.receiver_openid = ? AND b.status = 'pending'
       ORDER BY b.created_at DESC`,
      [receiverOpenid]
    );

    // 手机号脱敏
    const maskedRequests = requests.map(r => ({
      ...r,
      sender_phone: r.sender_phone ? r.sender_phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2') : '未知'
    }));

    return success(res, maskedRequests);
  } catch (err) {
    console.error('获取待确认请求失败:', err);
    return error(res, '获取失败', 'GET_PENDING_FAILED', 500);
  }
});

/**
 * POST /api/bindings/confirm-request
 * 接收者确认绑定
 */
router.post('/confirm-request', authMiddleware, async (req, res) => {
  try {
    const receiverOpenid = req.user.openid;
    const { request_id } = req.body;

    if (!request_id) return validationError(res, 'request_id 是必填参数');

    const binding = await query(
      `SELECT sender_openid FROM user_bindings WHERE id = ? AND receiver_openid = ? AND status = 'pending'`,
      [request_id, receiverOpenid]
    );

    if (binding.length === 0) {
      return error(res, '请求不存在或已处理', 'REQUEST_INVALID', 404);
    }

    await query(
      `UPDATE user_bindings SET status = 'active', updated_at = NOW() WHERE id = ?`,
      [request_id]
    );

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
router.post('/reject-request', authMiddleware, async (req, res) => {
  try {
    const receiverOpenid = req.user.openid;
    const { request_id } = req.body;

    if (!request_id) return validationError(res, 'request_id 是必填参数');

    await query(
      `UPDATE user_bindings SET status = 'revoked', updated_at = NOW() 
       WHERE id = ? AND receiver_openid = ? AND status = 'pending'`,
      [request_id, receiverOpenid]
    );

    return success(res, { message: '已拒绝' });
  } catch (err) {
    console.error('拒绝绑定失败:', err);
    return error(res, '拒绝失败', 'REJECT_REQUEST_FAILED', 500);
  }
});

module.exports = router;
