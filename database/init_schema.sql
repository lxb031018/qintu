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
    `nickname` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '用户昵称',
    `avatar_url` VARCHAR(256) NULL DEFAULT '' COMMENT '头像 URL',
    `last_login_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后登录时间',
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

    PRIMARY KEY (`user_A`, `user_B`),
    KEY `idx_user_A` (`user_A`),
    KEY `idx_user_B` (`user_B`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='用户绑定关系表 - 关系平等，解除绑定即删除记录';