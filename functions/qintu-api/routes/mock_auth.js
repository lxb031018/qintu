/**
 * Mock 认证路由
 * 
 * 职责：
 * 1. 模拟 CloudBase Auth API 行为 (验证码、登录、注册)
 * 2. 维护内存数据 (mockCodes, userPhoneMap)
 * 3. 使用全局配置消除硬编码
 */

const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const config = require('../config');
const { normalizePhone, isValidChinesePhone, maskPhone } = require('../lib/utils/phone');

// 🌟 初始化全局 Mock 数据
if (!global.mockCodes) global.mockCodes = {};
if (!global.userPhoneMap) global.userPhoneMap = {};

// 🌟 是否开发环境（控制调试日志）
const isDev = process.env.NODE_ENV !== 'production';

// 1. 发送验证码 (POST /auth/v1/verification)
router.post('/auth/v1/verification', async (req, res) => {
  try {
    const { phone_number } = req.body;
    if (!phone_number) {
      if (isDev) console.error(`[Mock Auth] ❌ 缺少 phone_number 字段`);
      return res.status(400).json({ code: 400, message: 'Missing phone_number' });
    }

    const finalPhone = normalizePhone(phone_number);

    if (isDev) {
      console.log(`[Mock Auth] 📱 规范化后: ${finalPhone}, 原始: ${phone_number}`);
    }

    if (!isValidChinesePhone(finalPhone)) {
      if (isDev) console.error(`[Mock Auth] ❌ 手机号格式不正确: ${finalPhone}`);
      return res.status(400).json({ code: 400, message: '手机号格式不正确（应为 11 位中国手机号）' });
    }

    // 🌟 动态生成 6 位验证码
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const verification_id = config.PREFIX.MOCK_CODE_VID + Date.now();

    global.mockCodes[verification_id] = {
      code: verificationCode,
      phone: finalPhone,  // 🌟 存入 11 位手机号
      expiresAt: Date.now() + config.AUTH.CODE_EXPIRES_MS
    };

    // 🌟 开发环境打印验证码（生产环境应通过短信发送）
    if (isDev) console.log(`[Mock Auth] 📱 发送验证码给 ${maskPhone(finalPhone)}: ${verificationCode}`);

    return res.json({ code: 0, message: 'OK', verification_id });
  } catch (err) {
    console.error('[Mock Auth] 发送验证码失败:', err);
    return res.status(500).json({ code: 500, message: 'Server Error' });
  }
});

// 2. 验证验证码 (POST /auth/v1/verification/verify)
router.post('/auth/v1/verification/verify', async (req, res) => {
  try {
    const { verification_id, verification_code } = req.body;
    const data = global.mockCodes[verification_id];

    // 🌟 检查验证码是否存在
    if (!data) {
      return res.status(400).json({ code: 40003, message: '验证码不存在或已过期' });
    }

    // 🌟 检查验证码是否过期
    if (Date.now() > data.expiresAt) {
      delete global.mockCodes[verification_id]; // 清理过期验证码
      return res.status(400).json({ code: 40004, message: '验证码已过期，请重新获取' });
    }

    // 🌟 检查验证码是否正确
    if (data.code !== verification_code) {
      return res.status(400).json({ code: 40002, message: '验证码错误' });
    }

    // 验证成功，清理已使用的验证码
    delete global.mockCodes[verification_id];

    // 🌟 核心：生成 ID 并同步给电话本
    const openid = config.PREFIX.OPENID + crypto.createHash('md5').update(data.phone).digest('hex').substring(0, 16);
    global.userPhoneMap[data.phone] = openid; // 存入电话本

    if (isDev) console.log(`[Mock Auth] ✅ 验证成功: ${maskPhone(data.phone)} -> ${openid}`);
    return res.json({
      code: 0,
      access_token: config.PREFIX.ACCESS_TOKEN + openid,
      openid: openid,
      verification_token: config.PREFIX.V_TOKEN + openid
    });
  } catch (err) {
    console.error('[Mock Auth] 验证验证码失败:', err);
    return res.status(500).json({ code: 500, message: 'Server Error' });
  }
});

// 3. 登录接口 (POST /auth/v1/signin)
router.post('/auth/v1/signin', async (req, res) => {
  try {
    const { verification_token } = req.body;
    if (isDev) console.log(`[Mock Auth] 登录请求`);

    // 简单解析 openid
    const openid = verification_token ? verification_token.replace(config.PREFIX.V_TOKEN, '') : 'mock_user';

    return res.json({
      code: 0,
      access_token: config.PREFIX.ACCESS_TOKEN + openid,
      refresh_token: config.PREFIX.REFRESH_TOKEN + openid,
      openid: openid,
      user_type: 'sender'
    });
  } catch (err) {
    return res.status(500).json({ code: 500, message: 'Server Error' });
  }
});

// 4. 注册接口 (POST /auth/v1/signup)
router.post('/auth/v1/signup', async (req, res) => {
  try {
    const { verification_token, phone_number } = req.body;
    if (isDev) console.log(`[Mock Auth] 注册请求`);

    const openid = verification_token ? verification_token.replace(config.PREFIX.V_TOKEN, '') : 'mock_user';

    return res.json({
      code: 0,
      access_token: config.PREFIX.ACCESS_TOKEN + openid,
      refresh_token: config.PREFIX.REFRESH_TOKEN + openid,
      openid: openid,
      user_type: 'sender'
    });
  } catch (err) {
    return res.status(500).json({ code: 500, message: 'Server Error' });
  }
});

// 5. 刷新 Token (POST /api/auth/refresh-token)
router.post('/api/auth/refresh-token', async (req, res) => {
  try {
    const { refresh_token } = req.body;
    if (isDev) console.log(`[Mock Auth] 刷新 Token 请求`);

    let openid = 'unknown_user';
    if (refresh_token && refresh_token.includes(config.PREFIX.OPENID)) {
       openid = config.PREFIX.OPENID + refresh_token.split(config.PREFIX.OPENID)[1];
    }

    return res.json({
      code: 0,
      message: '操作成功',
      access_token: config.PREFIX.ACCESS_TOKEN + openid,
      refresh_token: config.PREFIX.REFRESH_TOKEN + openid,
      expires_in: config.AUTH.TOKEN_EXPIRES_S,
      openid: openid,
      user_type: 'sender',
      token_type: 'Bearer'
    });
  } catch (err) {
    return res.status(500).json({ code: 500, message: 'Server Error' });
  }
});

module.exports = router;
