/**
 * 云函数配置管理
 *
 * 从环境变量或 .env 文件读取配置
 */

require('dotenv').config();

module.exports = {
  // CloudBase 配置
  CLOUDBASE: {
    ENV_ID: process.env.CLOUDBASE_ENV_ID || process.env.ENV_ID || '',
    PUBLISHABLE_KEY: process.env.CLOUDBASE_PUBLISHABLE_KEY || process.env.PUBLISHABLE_KEY || '',
  },

  // 服务器配置
  SERVER: {
    PORT: parseInt(process.env.LOCAL_SERVER_PORT || process.env.PORT || '9000', 10),
  },

  // CORS 配置
  CORS: {
    origins: [
      'http://localhost:3000',
      'http://127.0.0.1:3000',
      process.env.LOCAL_SERVER_IP ? `http://${process.env.LOCAL_SERVER_IP}:3000` : '',
    ].filter(Boolean),
    credentials: true,
  },

  // 数据库配置
  DATABASE: {
    PASSWORD: process.env.DB_PASSWORD || '',
  },

  // AI 配置
  AI: {
    DEFAULT_AGENT: process.env.AI_DEFAULT_AGENT || 'qwen',
  },

  // Mock 认证配置（用于本地测试，节省 CloudBase 配额）
  PREFIX: {
    MOCK_CODE_VID: 'mock_vid_',
    OPENID: 'mock_openid_',
    ACCESS_TOKEN: 'mock_at_',
    REFRESH_TOKEN: 'mock_rt_',
    V_TOKEN: 'mock_vt_',
  },

  // 认证配置
  AUTH: {
    CODE_EXPIRES_MS: 5 * 60 * 1000, // 验证码 5 分钟过期
    TOKEN_EXPIRES_S: 7 * 24 * 3600, // Token 7 天过期
  },

  // 绑定限制配置
  LIMITS: {
    MAX_BINDINGS_PER_USER: 5,
    MAX_RECEIVERS_PER_SENDER: 5,
    MAX_SENDERS_PER_RECEIVER: 5,
  },

  // 绑定配置
  BINDING: {
    EXPIRES_MS: 7 * 24 * 3600 * 1000, // 绑定请求 7 天过期
  },
};
