-- ============================================================
-- 亲途 (qintu) - 数据库初始化脚本
-- 创建日期: 2026-05-19
-- 说明: 简化版，只保留 users 和 user_bindings 表
-- ============================================================

-- 设置字符集
SET NAMES utf8mb4;

-- ------------------------------------------------------------
-- 1. 用户表 (users)
-- 存储所有登录用户
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
    `user_ID` CHAR(36) NOT NULL COMMENT '用户唯一标识（UUID）',
    `phone` CHAR(11) NOT NULL COMMENT '手机号（11位数字）',
    `nickname` VARCHAR(32) NULL DEFAULT '' COMMENT '用户昵称',
    `avatar_url` VARCHAR(256) NULL DEFAULT '' COMMENT '头像 URL',
    `access_token` VARCHAR(256) NULL COMMENT '访问令牌',
    `refresh_token` VARCHAR(256) NULL COMMENT '刷新令牌',
    `token_expires_at` DATETIME NULL COMMENT 'Token 过期时间',
    `device_id` VARCHAR(128) NULL COMMENT '登录的设备ID',
    `last_active_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最近活跃时间',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    PRIMARY KEY (`user_ID`),
    UNIQUE KEY `uk_phone` (`phone`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='用户表';

-- ------------------------------------------------------------
-- 2. 绑定关系表 (user_bindings)
-- 记录用户之间的绑定关系，关系平等，双向可发导航任务
-- 存储规则：user_A < user_B（字符串比较，小的在前）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `user_bindings`;
CREATE TABLE `user_bindings` (
    `user_A` CHAR(36) NOT NULL COMMENT '用户A的 user_ID（较小者）',
    `user_B` CHAR(36) NOT NULL COMMENT '用户B的 user_ID（较大者）',
    `name_A_to_B` VARCHAR(32) NULL DEFAULT NULL COMMENT 'A对B的称呼',
    `name_B_to_A` VARCHAR(32) NULL DEFAULT NULL COMMENT 'B对A的称呼',

    PRIMARY KEY (`user_A`, `user_B`),
    KEY `idx_user_A` (`user_A`),
    KEY `idx_user_B` (`user_B`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='用户绑定关系表 - 关系平等，解除绑定即删除记录';

-- ------------------------------------------------------------
-- 3. 绑定请求表 (binding_requests)
-- 记录用户发送的绑定请求，等待对方确认后才建立绑定关系
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `binding_requests`;
CREATE TABLE `binding_requests` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `sender_user_ID` CHAR(36) NOT NULL COMMENT '发送者user_ID',
    `receiver_user_ID` CHAR(36) NOT NULL COMMENT '接收者user_ID',
    `sender_name` VARCHAR(32) NULL DEFAULT NULL COMMENT '发送者对接收者的称呼',
    `receiver_name` VARCHAR(32) NULL DEFAULT NULL COMMENT '接收者对发送者的称呼',
    `status` ENUM('pending', 'accepted', 'rejected', 'expired') DEFAULT 'pending' COMMENT '请求状态',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `expires_at` TIMESTAMP NOT NULL COMMENT '过期时间',

    PRIMARY KEY (`id`),
    KEY `idx_receiver` (`receiver_user_ID`, `status`),
    KEY `idx_sender` (`sender_user_ID`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='绑定请求表 - 需要对方确认才能建立绑定关系';