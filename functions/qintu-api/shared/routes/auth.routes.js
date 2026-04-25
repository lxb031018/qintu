/**
 * 认证路由
 */

const express = require('express');
const router = express.Router();
const AuthController = require('../../auth/controllers/auth.controller');
const AuthService = require('../../auth/services/auth.service');
const { createRepositories } = require('../../repositories');

// 创建依赖
const { userRepo } = createRepositories('memory');
const authService = new AuthService(userRepo);
const authController = new AuthController(authService);

// 发送验证码
router.post('/v1/verification', (req, res) => authController.sendVerification(req, res));

// 验证验证码
router.post('/v1/verification/verify', (req, res) => authController.verifyCode(req, res));

// 登录
router.post('/v1/signin', (req, res) => authController.signin(req, res));

// 注册
router.post('/v1/signup', (req, res) => authController.signup(req, res));

// 刷新 Token
router.post('/api/auth/refresh-token', (req, res) => authController.refreshToken(req, res));

module.exports = router;
