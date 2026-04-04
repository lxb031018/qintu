-- ============================================================
-- 亲途 (qintu) - 数据库初始化脚本
-- 环境 ID: qintu-cloudebase-5f5bpuj13bc6467
-- 数据库类型: MySQL
-- 创建日期: 2026-04-04
-- ============================================================

-- 使用说明：
-- 1. 登录 CloudBase 控制台：https://tcb.cloud.tencent.com/
-- 2. 进入 MySQL 数据库管理页面
-- 3. 执行此脚本创建所有表和索引
-- ============================================================

-- 设置字符集
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- 1. 用户表 (users)
-- 存储所有登录用户，支持灵活角色（发送者/接收者/两者皆可）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
    `openid` VARCHAR(64) NOT NULL COMMENT 'CloudBase Auth 用户唯一标识',
    `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号（带国家码：+86 13800138000）',
    `nickname` VARCHAR(50) DEFAULT NULL COMMENT '用户昵称',
    `user_type` ENUM('sender', 'receiver', 'both') NOT NULL DEFAULT 'both' 
        COMMENT '用户角色类型：sender=发送者, receiver=接收者, both=两者皆可',
    `avatar_url` VARCHAR(500) DEFAULT NULL COMMENT '头像 URL',
    `status` ENUM('active', 'disabled') NOT NULL DEFAULT 'active' 
        COMMENT '账号状态：active=正常, disabled=禁用',
    `last_login_at` TIMESTAMP NULL DEFAULT NULL COMMENT '最后登录时间',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    PRIMARY KEY (`openid`),
    UNIQUE KEY `uk_phone` (`phone`),
    KEY `idx_user_type` (`user_type`),
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='用户表 - 存储所有用户的基本信息和角色';

-- ------------------------------------------------------------
-- 2. 绑定关系表 (user_bindings)
-- 核心表：建立发送者与接收者之间的绑定关系
-- 只有通过绑定，发送者才能向接收者发送导航指令
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `user_bindings`;
CREATE TABLE `user_bindings` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '绑定关系自增 ID',
    `sender_openid` VARCHAR(64) NOT NULL COMMENT '发送者 openid（外键关联 users 表）',
    `receiver_openid` VARCHAR(64) NOT NULL COMMENT '接收者 openid（外键关联 users 表）',
    `bind_code` VARCHAR(8) NOT NULL COMMENT '绑定码（6-8位字母数字组合，用于配对）',
    `status` ENUM('pending', 'active', 'expired', 'revoked') NOT NULL DEFAULT 'active' 
        COMMENT '绑定状态：pending=待确认, active=生效中, expired=已过期, revoked=已撤销',
    `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注（如：给父亲的绑定关系）',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `expired_at` TIMESTAMP NULL DEFAULT NULL COMMENT '过期时间（可选）',
    
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_sender_receiver` (`sender_openid`, `receiver_openid`) 
        COMMENT '同一对发送者-接收者只能有一条绑定',
    UNIQUE KEY `uk_bind_code` (`bind_code`) 
        COMMENT '绑定码全局唯一',
    KEY `idx_receiver_openid` (`receiver_openid`) 
        COMMENT '用于查询某人被谁绑定为接收者',
    KEY `idx_sender_openid` (`sender_openid`) 
        COMMENT '用于查询某人绑定了哪些接收者',
    KEY `idx_status` (`status`),
    
    -- 外键约束（可选，如果 CloudBase MySQL 支持）
    CONSTRAINT `fk_binding_sender` FOREIGN KEY (`sender_openid`) 
        REFERENCES `users` (`openid`) ON DELETE CASCADE,
    CONSTRAINT `fk_binding_receiver` FOREIGN KEY (`receiver_openid`) 
        REFERENCES `users` (`openid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='用户绑定关系表 - 建立发送者与接收者的配对关系';

-- ------------------------------------------------------------
-- 3. 导航任务表 (navigation_tasks)
-- 存储发送者下发给接收者的导航任务和路线数据
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `navigation_tasks`;
CREATE TABLE `navigation_tasks` (
    `task_id` VARCHAR(64) NOT NULL COMMENT '导航任务 ID（UUID 或雪花算法生成）',
    `sender_openid` VARCHAR(64) NOT NULL COMMENT '发送者 openid',
    `receiver_openid` VARCHAR(64) NOT NULL COMMENT '接收者 openid',
    
    -- 任务状态
    `status` ENUM('waiting', 'accepted', 'navigating', 'finished', 'cancelled', 'expired') 
        NOT NULL DEFAULT 'waiting' 
        COMMENT '任务状态：waiting=等待接受, accepted=已接受, navigating=导航中, finished=已完成, cancelled=已取消, expired=已过期',
    
    -- 起点信息（可选，默认为接收者当前位置）
    `start_name` VARCHAR(200) DEFAULT NULL COMMENT '起点名称',
    `start_latitude` DECIMAL(10, 7) DEFAULT NULL COMMENT '起点纬度',
    `start_longitude` DECIMAL(10, 7) DEFAULT NULL COMMENT '起点经度',
    `start_address` VARCHAR(500) DEFAULT NULL COMMENT '起点地址',
    
    -- 终点信息（必填）
    `end_name` VARCHAR(200) NOT NULL COMMENT '终点名称',
    `end_latitude` DECIMAL(10, 7) NOT NULL COMMENT '终点纬度',
    `end_longitude` DECIMAL(10, 7) NOT NULL COMMENT '终点经度',
    `end_address` VARCHAR(500) DEFAULT NULL COMMENT '终点地址',
    
    -- 路线数据（高德地图返回的完整路线 JSON）
    `route_data` JSON DEFAULT NULL COMMENT '高德地图路线数据（包含路径点、转向指令等）',
    `route_summary` JSON DEFAULT NULL COMMENT '路线摘要（总距离、预计时间等，便于快速查询）',
    
    -- 导航方式
    `transport_mode` ENUM('drive', 'walk', 'bike', 'bus') NOT NULL DEFAULT 'drive' 
        COMMENT '出行方式：drive=驾车, walk=步行, bike=骑行, bus=公交',
    
    -- 时间戳
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
    `accepted_at` TIMESTAMP NULL DEFAULT NULL COMMENT '接收者接受时间',
    `started_at` TIMESTAMP NULL DEFAULT NULL COMMENT '开始导航时间',
    `finished_at` TIMESTAMP NULL DEFAULT NULL COMMENT '完成时间',
    `cancelled_at` TIMESTAMP NULL DEFAULT NULL COMMENT '取消时间',
    `cancel_reason` VARCHAR(200) DEFAULT NULL COMMENT '取消原因',
    `cancelled_by` ENUM('sender', 'receiver', 'system') DEFAULT NULL 
        COMMENT '取消方',
    
    -- 统计信息
    `distance_meters` INT DEFAULT NULL COMMENT '路线总距离（米）',
    `duration_seconds` INT DEFAULT NULL COMMENT '预计耗时（秒）',
    
    PRIMARY KEY (`task_id`),
    KEY `idx_receiver_status` (`receiver_openid`, `status`) 
        COMMENT '查询接收者的待处理/进行中任务',
    KEY `idx_sender_status` (`sender_openid`, `status`) 
        COMMENT '查询发送者发出的任务',
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`),
    
    -- 外键约束
    CONSTRAINT `fk_task_sender` FOREIGN KEY (`sender_openid`) 
        REFERENCES `users` (`openid`) ON DELETE CASCADE,
    CONSTRAINT `fk_task_receiver` FOREIGN KEY (`receiver_openid`) 
        REFERENCES `users` (`openid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='导航任务表 - 存储发送者下发的导航指令和路线';

-- ------------------------------------------------------------
-- 4. 实时位置表 (real_time_locations)
-- 存储接收者在导航过程中的实时位置
-- 仅当发送者点击"查看位置"时更新，节省资源
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `real_time_locations`;
CREATE TABLE `real_time_locations` (
    `receiver_openid` VARCHAR(64) NOT NULL COMMENT '接收者 openid（主键）',
    `task_id` VARCHAR(64) DEFAULT NULL COMMENT '当前导航任务 ID',
    
    -- 位置信息
    `latitude` DECIMAL(10, 7) NOT NULL COMMENT '当前位置纬度',
    `longitude` DECIMAL(10, 7) NOT NULL COMMENT '当前位置经度',
    `accuracy` DECIMAL(6, 2) DEFAULT NULL COMMENT '定位精度（米）',
    `speed` DECIMAL(5, 2) DEFAULT NULL COMMENT '当前速度（km/h）',
    `bearing` DECIMAL(5, 2) DEFAULT NULL COMMENT '方向角（0-360度）',
    `altitude` DECIMAL(8, 2) DEFAULT NULL COMMENT '海拔高度（米）',
    
    -- 时间戳
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 
        COMMENT '最后更新时间',
    
    -- 状态
    `is_navigating` TINYINT(1) NOT NULL DEFAULT 0 
        COMMENT '是否正在导航：0=否, 1=是',
    `is_sharing` TINYINT(1) NOT NULL DEFAULT 0 
        COMMENT '是否正在共享位置：0=否, 1=是',
    
    PRIMARY KEY (`receiver_openid`),
    KEY `idx_task_id` (`task_id`),
    KEY `idx_updated_at` (`updated_at`),
    KEY `idx_is_sharing` (`is_sharing`),
    
    -- 外键约束
    CONSTRAINT `fk_location_receiver` FOREIGN KEY (`receiver_openid`) 
        REFERENCES `users` (`openid`) ON DELETE CASCADE,
    CONSTRAINT `fk_location_task` FOREIGN KEY (`task_id`) 
        REFERENCES `navigation_tasks` (`task_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='实时位置表 - 存储接收者导航时的实时位置（仅共享时更新）';

-- ------------------------------------------------------------
-- 5. 操作日志表 (operation_logs)（可选，用于审计和调试）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `operation_logs`;
CREATE TABLE `operation_logs` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志 ID',
    `user_openid` VARCHAR(64) NOT NULL COMMENT '操作用户 openid',
    `action` VARCHAR(100) NOT NULL COMMENT '操作类型',
    `target_type` VARCHAR(50) DEFAULT NULL COMMENT '目标类型（binding/task等）',
    `target_id` VARCHAR(64) DEFAULT NULL COMMENT '目标 ID',
    `details` JSON DEFAULT NULL COMMENT '操作详情',
    `ip_address` VARCHAR(45) DEFAULT NULL COMMENT '客户端 IP',
    `user_agent` VARCHAR(500) DEFAULT NULL COMMENT '客户端 User-Agent',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    
    PRIMARY KEY (`id`),
    KEY `idx_user_action` (`user_openid`, `action`),
    KEY `idx_target` (`target_type`, `target_id`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='操作日志表 - 记录关键操作用于审计和排查问题';

-- ------------------------------------------------------------
-- 6. 初始化视图：活跃绑定关系
-- ------------------------------------------------------------
DROP VIEW IF EXISTS `v_active_bindings`;
CREATE VIEW `v_active_bindings` AS
SELECT 
    b.id AS binding_id,
    b.bind_code,
    b.status,
    b.remark,
    s.openid AS sender_openid,
    s.nickname AS sender_nickname,
    s.phone AS sender_phone,
    r.openid AS receiver_openid,
    r.nickname AS receiver_nickname,
    r.phone AS receiver_phone,
    b.created_at,
    b.updated_at
FROM `user_bindings` b
INNER JOIN `users` s ON b.sender_openid = s.openid
INNER JOIN `users` r ON b.receiver_openid = r.openid
WHERE b.status = 'active'
ORDER BY b.created_at DESC;

-- ------------------------------------------------------------
-- 7. 初始化视图：接收者待处理的导航任务
-- ------------------------------------------------------------
DROP VIEW IF EXISTS `v_pending_tasks`;
CREATE VIEW `v_pending_tasks` AS
SELECT 
    t.task_id,
    t.sender_openid,
    s.nickname AS sender_nickname,
    t.receiver_openid,
    t.status,
    t.start_name,
    t.end_name,
    t.end_address,
    t.transport_mode,
    t.distance_meters,
    t.duration_seconds,
    t.route_summary,
    t.created_at,
    TIMESTAMPDIFF(MINUTE, t.created_at, NOW()) AS minutes_waiting
FROM `navigation_tasks` t
INNER JOIN `users` s ON t.sender_openid = s.openid
WHERE t.status = 'waiting'
ORDER BY t.created_at DESC;

-- 恢复外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 脚本执行完成！
-- ============================================================
-- 后续步骤：
-- 1. 验证表是否创建成功：SHOW TABLES;
-- 2. 查看表结构：DESC users;
-- 3. 测试插入数据验证外键约束
-- 4. 在 Flutter 端配置数据库连接和 API 调用
-- ============================================================
