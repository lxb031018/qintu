-- ============================================================
-- 迁移脚本: 添加 nickname 字段
-- 日期: 2026-05-21
-- 说明: 为 users 表添加昵称字段
-- ============================================================

-- 检查字段是否已存在，不存在则添加
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'users'
    AND COLUMN_NAME = 'nickname'
);

-- 添加 nickname 字段（如果不存在）
SET @sql = IF(@column_exists = 0,
    'ALTER TABLE `users` ADD COLUMN `nickname` VARCHAR(64) NOT NULL DEFAULT \'\' COMMENT \'用户昵称\' AFTER `phone`',
    'SELECT \'nickname 字段已存在\'');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
