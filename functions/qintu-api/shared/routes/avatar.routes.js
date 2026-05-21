/**
 * 头像上传路由
 */

const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const { requireAuth } = require('../middleware/auth.middleware');

// 配置文件上传存储
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../../uploads/avatars'));
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${uuidv4()}${ext}`);
  }
});

// 文件过滤器：只允许图片
const fileFilter = (req, file, cb) => {
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('只支持 JPG、PNG、GIF、WebP 格式图片'), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 2 * 1024 * 1024 // 限制 2MB
  }
});

/**
 * 创建头像路由
 * @param {Object} services - 服务实例
 */
function createAvatarRoutes(services) {
  // 上传头像（需要认证）
  router.post('/upload', requireAuth, upload.single('avatar'), (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          code: 'NO_FILE',
          message: '请选择要上传的头像图片'
        });
      }

      // 返回访问路径
      const avatarUrl = `/uploads/avatars/${req.file.filename}`;

      res.json({
        success: true,
        data: {
          avatarUrl,
          filename: req.file.filename,
          size: req.file.size
        }
      });
    } catch (error) {
      console.error('[Avatar] 上传失败:', error);
      res.status(500).json({
        code: 'UPLOAD_FAILED',
        message: '头像上传失败'
      });
    }
  });

  return router;
}

module.exports = createAvatarRoutes;