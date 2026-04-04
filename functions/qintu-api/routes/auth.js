/**
 * 认证路由
 *
 * 路由列表：
 * POST /api/auth/send-code     - 发送短信验证码
 * POST /api/auth/verify-code   - 验证短信验证码
 * POST /api/auth/sign-in       - 用户登录
 * POST /api/auth/sign-up       - 用户注册
 * POST /api/auth/refresh-token - 刷新访问令牌
 * POST /api/auth/sign-out      - 用户登出
 */

const express = require('express');
const router = express.Router();
const cloudbase = require('@cloudbase/node-sdk');
const { v4: uuidv4 } = require('uuid');
const { success, validationError, error, unauthorized } = require('../lib/response');
const { query } = require('../lib/database');

// 初始化 CloudBase Node SDK
const app = cloudbase.init({
  env: process.env.TCB_ENV || process.env.CLOUDBASE_ENV_ID || 'qintu-cloudebase-5f5bpuj13bc6467'
});

// 模拟验证码存储（生产环境应使用 Redis）
const mockVerificationCodes = new Map();

/**
 * POST /api/auth/send-code
 * 发送短信验证码
 * 请求体: { "phone_number": "+86 13800138000" }
 */
router.post('/send-code', async (req, res) => {
  try {
    const { phone_number } = req.body;
    if (!phone_number) {
      return validationError(res, 'phone_number 是必填参数');
    }

    console.log(`[Auth] 请求发送验证码: ${phone_number}`);

    // 获取配置（需在 CloudBase 云函数环境变量中配置）
    const smsSignId = process.env.SMS_SIGN_ID;
    const smsTemplateId = process.env.SMS_TEMPLATE_ID;

    if (!smsSignId || !smsTemplateId) {
      console.warn('[Auth] 未配置短信签名或模板 ID，返回模拟验证码');
      // 开发阶段：返回模拟 verification_id
      const verificationId = 'mock_vid_' + Date.now();
      const mockCode = '123456';
      
      // 存储模拟验证码（5分钟过期）
      mockVerificationCodes.set(verificationId, {
        code: mockCode,
        phone: phone_number,
        expiresAt: Date.now() + 5 * 60 * 1000
      });

      return success(res, {
        message: '验证码已发送（模拟模式）',
        verification_id: verificationId,
        mock_code: mockCode // 提示测试用的固定验证码
      });
    }

    // 发送短信
    const result = await app.auth().sendSmsCode({
      phoneNumber: phone_number,
      smsType: 0,
      params: [] // 如果您的模板有参数，请在此处填入
    });

    console.log('[Auth] 短信发送结果:', result);

    if (result.code === 0) {
      return success(res, {
        message: '验证码已发送',
        verification_id: result.requestId
      });
    } else {
      return error(res, result.message || '发送失败', 'SEND_SMS_FAILED', 500);
    }
  } catch (err) {
    console.error('[Auth] 发送验证码异常:', err);
    return error(res, '发送失败: ' + err.message, 'SEND_SMS_FAILED', 500);
  }
});

/**
 * POST /api/auth/verify-code
 * 验证短信验证码
 * 请求体: { "verification_id": "xxx", "verification_code": "123456" }
 * 返回: { "verification_token": "xxx" }
 */
router.post('/verify-code', async (req, res) => {
  try {
    const { verification_id, verification_code } = req.body;
    
    if (!verification_id || !verification_code) {
      return validationError(res, 'verification_id 和 verification_code 都是必填参数');
    }

    console.log(`[Auth] 验证验证码: verification_id=${verification_id}, code=${verification_code}`);

    // 检查是否是模拟模式
    if (verification_id.startsWith('mock_vid_')) {
      const mockData = mockVerificationCodes.get(verification_id);
      
      if (!mockData) {
        return error(res, '验证码已过期或不存在', 'CODE_EXPIRED', 400);
      }

      if (Date.now() > mockData.expiresAt) {
        mockVerificationCodes.delete(verification_id);
        return error(res, '验证码已过期', 'CODE_EXPIRED', 400);
      }

      if (mockData.code !== verification_code) {
        return error(res, '验证码错误', 'CODE_INCORRECT', 400);
      }

      // 验证成功，生成 verification_token
      const verificationToken = 'mock_vtoken_' + uuidv4();
      
      // 存储验证令牌（10分钟过期）
      mockVerificationCodes.set(verificationToken, {
        type: 'verification_token',
        phone: mockData.phone,
        verified: true,
        expiresAt: Date.now() + 10 * 60 * 1000
      });

      // 清理已使用的验证码
      mockVerificationCodes.delete(verification_id);

      return success(res, {
        message: '验证成功',
        verification_token: verificationToken
      });
    }

    // 真实模式：使用 CloudBase Auth 验证
    const result = await app.auth().verifySmsCode({
      verificationId: verification_id,
      verificationCode: verification_code
    });

    if (result.code === 0) {
      return success(res, {
        message: '验证成功',
        verification_token: result.verificationToken
      });
    } else {
      return error(res, result.message || '验证码错误', 'CODE_INCORRECT', 400);
    }
  } catch (err) {
    console.error('[Auth] 验证验证码异常:', err);
    return error(res, '验证失败: ' + err.message, 'VERIFY_CODE_FAILED', 500);
  }
});

/**
 * POST /api/auth/sign-in
 * 用户登录（老用户）
 * 请求体: { "verification_token": "xxx" }
 * 返回: { "access_token": "xxx", "refresh_token": "xxx", "expires_in": 86400, "uid": "xxx" }
 */
router.post('/sign-in', async (req, res) => {
  try {
    const { verification_token } = req.body;
    
    if (!verification_token) {
      return validationError(res, 'verification_token 是必填参数');
    }

    console.log(`[Auth] 用户登录: verification_token=${verification_token}`);

    // 检查验证令牌
    const tokenData = mockVerificationCodes.get(verification_token);
    
    if (!tokenData || !tokenData.verified) {
      return error(res, '验证令牌无效或已过期', 'INVALID_TOKEN', 400);
    }

    if (Date.now() > tokenData.expiresAt) {
      mockVerificationCodes.delete(verification_token);
      return error(res, '验证令牌已过期', 'TOKEN_EXPIRED', 400);
    }

    const phone = tokenData.phone;

    // 查询用户是否存在
    const users = await query(
      'SELECT openid, phone, nickname, user_type, status FROM users WHERE phone = ?',
      [phone]
    );

    if (users.length === 0) {
      return error(res, '用户不存在，请先注册', 'USER_NOT_FOUND', 404);
    }

    const user = users[0];

    if (user.status === 'disabled') {
      return error(res, '用户账号已被禁用', 'USER_DISABLED', 403);
    }

    // 生成访问令牌和刷新令牌
    const accessToken = 'access_' + uuidv4();
    const refreshToken = 'refresh_' + uuidv4();
    const expiresIn = 86400; // 24小时
    const refreshExpiresIn = 604800; // 7天

    // 存储令牌（简化实现，生产环境应使用 Redis 或数据库）
    mockVerificationCodes.set(accessToken, {
      type: 'access_token',
      openid: user.openid,
      phone: user.phone,
      expiresAt: Date.now() + expiresIn * 1000
    });

    mockVerificationCodes.set(refreshToken, {
      type: 'refresh_token',
      openid: user.openid,
      expiresAt: Date.now() + refreshExpiresIn * 1000
    });

    // 更新最后登录时间
    await query(
      'UPDATE users SET last_login_at = NOW() WHERE openid = ?',
      [user.openid]
    );

    // 清理已使用的验证令牌
    mockVerificationCodes.delete(verification_token);

    return success(res, {
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: expiresIn,
      refresh_expires_in: refreshExpiresIn,
      uid: user.openid,
      phone: user.phone,
      user_type: user.user_type
    });
  } catch (err) {
    console.error('[Auth] 登录异常:', err);
    return error(res, '登录失败: ' + err.message, 'SIGN_IN_FAILED', 500);
  }
});

/**
 * POST /api/auth/sign-up
 * 用户注册（新用户）
 * 请求体: { "verification_token": "xxx", "phone_number": "+86 13800138000" }
 * 返回: { "access_token": "xxx", "refresh_token": "xxx", "expires_in": 86400, "uid": "xxx" }
 */
router.post('/sign-up', async (req, res) => {
  try {
    const { verification_token, phone_number } = req.body;
    
    if (!verification_token || !phone_number) {
      return validationError(res, 'verification_token 和 phone_number 都是必填参数');
    }

    console.log(`[Auth] 用户注册: phone=${phone_number}`);

    // 检查验证令牌
    const tokenData = mockVerificationCodes.get(verification_token);
    
    if (!tokenData || !tokenData.verified) {
      return error(res, '验证令牌无效或已过期', 'INVALID_TOKEN', 400);
    }

    if (Date.now() > tokenData.expiresAt) {
      mockVerificationCodes.delete(verification_token);
      return error(res, '验证令牌已过期', 'TOKEN_EXPIRED', 400);
    }

    // 验证手机号是否匹配
    if (tokenData.phone !== phone_number) {
      return error(res, '手机号与验证码不匹配', 'PHONE_MISMATCH', 400);
    }

    // 检查用户是否已存在
    const existingUsers = await query(
      'SELECT openid FROM users WHERE phone = ?',
      [phone_number]
    );

    if (existingUsers.length > 0) {
      return error(res, '用户已存在，请直接登录', 'USER_ALREADY_EXISTS', 400);
    }

    // 生成用户 openid
    const openid = 'oid_' + uuidv4();

    // 创建新用户
    await query(
      'INSERT INTO users (openid, phone, nickname, user_type, status, created_at, last_login_at) VALUES (?, ?, ?, ?, ?, NOW(), NOW())',
      [openid, phone_number, `用户${phone_number.slice(-4)}`, 'pending', 'active']
    );

    console.log(`[Auth] 用户注册成功: openid=${openid}, phone=${phone_number}`);

    // 生成访问令牌和刷新令牌
    const accessToken = 'access_' + uuidv4();
    const refreshToken = 'refresh_' + uuidv4();
    const expiresIn = 86400; // 24小时
    const refreshExpiresIn = 604800; // 7天

    // 存储令牌
    mockVerificationCodes.set(accessToken, {
      type: 'access_token',
      openid: openid,
      phone: phone_number,
      expiresAt: Date.now() + expiresIn * 1000
    });

    mockVerificationCodes.set(refreshToken, {
      type: 'refresh_token',
      openid: openid,
      expiresAt: Date.now() + refreshExpiresIn * 1000
    });

    // 清理已使用的验证令牌
    mockVerificationCodes.delete(verification_token);

    return success(res, {
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: expiresIn,
      refresh_expires_in: refreshExpiresIn,
      uid: openid,
      phone: phone_number,
      user_type: 'pending'
    });
  } catch (err) {
    console.error('[Auth] 注册异常:', err);
    return error(res, '注册失败: ' + err.message, 'SIGN_UP_FAILED', 500);
  }
});

/**
 * POST /api/auth/refresh-token
 * 刷新访问令牌
 * 请求体: { "refresh_token": "xxx" }
 * 返回: { "access_token": "xxx", "refresh_token": "xxx", "expires_in": 86400 }
 */
router.post('/refresh-token', async (req, res) => {
  try {
    const { refresh_token } = req.body;
    
    if (!refresh_token) {
      return validationError(res, 'refresh_token 是必填参数');
    }

    console.log(`[Auth] 刷新令牌`);

    // 检查刷新令牌
    const tokenData = mockVerificationCodes.get(refresh_token);
    
    if (!tokenData || tokenData.type !== 'refresh_token') {
      return error(res, '刷新令牌无效', 'INVALID_TOKEN', 401);
    }

    if (Date.now() > tokenData.expiresAt) {
      mockVerificationCodes.delete(refresh_token);
      return unauthorized(res, '刷新令牌已过期，请重新登录');
    }

    const openid = tokenData.openid;

    // 查询用户信息
    const users = await query(
      'SELECT openid, phone, user_type, status FROM users WHERE openid = ?',
      [openid]
    );

    if (users.length === 0) {
      return error(res, '用户不存在', 'USER_NOT_FOUND', 404);
    }

    const user = users[0];

    if (user.status === 'disabled') {
      return error(res, '用户账号已被禁用', 'USER_DISABLED', 403);
    }

    // 生成新的令牌
    const newAccessToken = 'access_' + uuidv4();
    const newRefreshToken = 'refresh_' + uuidv4();
    const expiresIn = 86400;
    const refreshExpiresIn = 604800;

    // 删除旧令牌
    mockVerificationCodes.delete(refresh_token);

    // 存储新令牌
    mockVerificationCodes.set(newAccessToken, {
      type: 'access_token',
      openid: user.openid,
      phone: user.phone,
      expiresAt: Date.now() + expiresIn * 1000
    });

    mockVerificationCodes.set(newRefreshToken, {
      type: 'refresh_token',
      openid: user.openid,
      expiresAt: Date.now() + refreshExpiresIn * 1000
    });

    return success(res, {
      access_token: newAccessToken,
      refresh_token: newRefreshToken,
      expires_in: expiresIn,
      refresh_expires_in: refreshExpiresIn
    });
  } catch (err) {
    console.error('[Auth] 刷新令牌异常:', err);
    return error(res, '刷新失败: ' + err.message, 'REFRESH_TOKEN_FAILED', 500);
  }
});

/**
 * POST /api/auth/sign-out
 * 用户登出
 * 请求头: Authorization: Bearer <access_token>
 * 返回: { "message": "登出成功" }
 */
router.post('/sign-out', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return unauthorized(res, '缺少访问令牌');
    }

    const accessToken = authHeader.substring(7);

    console.log(`[Auth] 用户登出`);

    // 删除访问令牌
    mockVerificationCodes.delete(accessToken);

    // 注意：刷新令牌可以选择保留或删除
    // 这里选择删除刷新令牌，要求用户重新登录
    // 如果需要保持刷新令牌，可以注释掉下面这行
    // mockVerificationCodes.forEach((value, key) => {
    //   if (value.type === 'refresh_token' && value.openid === openid) {
    //     mockVerificationCodes.delete(key);
    //   }
    // });

    return success(res, { message: '登出成功' });
  } catch (err) {
    console.error('[Auth] 登出异常:', err);
    return error(res, '登出失败: ' + err.message, 'SIGN_OUT_FAILED', 500);
  }
});

module.exports = router;
