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
-- status: pending(待确认) / active(已绑定) / rejected(已拒绝/已过期)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `user_bindings`;
CREATE TABLE `user_bindings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '自增ID，用于API操作',
    `user_A` CHAR(36) NOT NULL COMMENT '用户A的 user_ID（较小者）',
    `user_B` CHAR(36) NOT NULL COMMENT '用户B的 user_ID（较大者）',
    `sender_user_ID` CHAR(36) NULL COMMENT '发送者 user_ID（发起绑定请求的人）',
    `name_A_to_B` VARCHAR(32) NULL DEFAULT NULL COMMENT 'A对B的称呼',
    `name_B_to_A` VARCHAR(32) NULL DEFAULT NULL COMMENT 'B对A的称呼',
    `status` VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending=待确认, active=已绑定, rejected=已拒绝/已过期',
    `expires_at` DATETIME NULL COMMENT 'pending状态过期时间',
    `bound_at` DATETIME NULL COMMENT '绑定成功时间',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    UNIQUE KEY `uk_user_pair` (`user_A`, `user_B`),
    KEY `idx_user_A` (`user_A`),
    KEY `idx_user_B` (`user_B`),
    KEY `idx_sender` (`sender_user_ID`),
    KEY `idx_status` (`status`),
    KEY `idx_receiver` (`user_B`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='用户绑定关系表 - 单表设计，pending状态为待确认的绑定请求';

-- 注意：已废弃 binding_requests 表，功能合并到 user_bindings 表