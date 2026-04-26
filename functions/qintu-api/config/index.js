/**
 * 全局配置文件
 *
 * 集中管理所有常量、环境变量和业务限制
 * 与前端 lib/constants 保持一致
 */

// CORS 白名单配置
// 生产环境请替换为实际的域名
const isDevelopment = process.env.NODE_ENV === 'development';

const CORS_ORIGINS = process.env.CORS_ORIGINS
  ? process.env.CORS_ORIGINS.split(',').map(s => s.trim())
  : isDevelopment
    ? [
        'http://localhost:3000',    // 本地开发
        'http://localhost:8080',    // 本地开发备用
        'http://127.0.0.1:3000',   // 本地开发
        'http://127.0.0.1:8080',   // 本地开发备用
      ]
    : [];

module.exports = {
  SERVER: {
    PORT: process.env.PORT || 9000,
    NODE_ENV: process.env.NODE_ENV || 'development',
  },

  // CORS 配置
  CORS: {
    origins: CORS_ORIGINS,
    credentials: true,
  },

  // 业务限制
  LIMITS: {
    MAX_BINDINGS_PER_USER: 5, // 互相绑定上限（统一）
  },

  // 认证相关配置
  AUTH: {
    // Mock 验证码
    MOCK_CODE: '123456',
    CODE_EXPIRES_MS: 5 * 60 * 1000, // 5分钟
    TOKEN_EXPIRES_S: 30 * 24 * 60 * 60, // 30天
  },

  // 数据格式前缀 (方便统一管理)
  PREFIX: {
    OPENID: 'oid_',
    MOCK_CODE_VID: 'mock_vid_',
    TOKEN: 'mock_token_',
    V_TOKEN: 'mock_vtoken_',
    ACCESS_TOKEN: 'mock_access_',
    REFRESH_TOKEN: 'mock_refresh_',
  },

  // 绑定请求过期时间
  BINDING: {
    EXPIRES_MS: 7 * 24 * 60 * 60 * 1000, // 7天
  },
};
