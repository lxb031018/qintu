# 测试环境设置指南

## 📋 前提条件

### 选项 1: 使用真实 MySQL（推荐）

1. **安装 MySQL**
   - Windows: 下载 https://dev.mysql.com/downloads/installer/
   - 或使用 XAMPP/WAMP 集成环境

2. **创建数据库**
   ```sql
   CREATE DATABASE qintu_test DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

3. **执行数据库迁移**
   ```bash
   mysql -u root -p qintu_test < database/init_schema.sql
   mysql -u root -p qintu_test < database/migrate_2026_04_09.sql
   ```

4. **配置环境变量**
   
   编辑 `functions/qintu-api/.env`：
   ```env
   NODE_ENV=development
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=你的MySQL密码
   DB_NAME=qintu_test
   ```

5. **启动服务**
   ```bash
   cd functions/qintu-api
   npm install
   npm run dev
   ```

6. **运行测试**
   ```bash
   # 测试绑定系统
   node test-binding-flow.js
   
   # 测试导航任务系统
   node test-task-flow.js
   ```

### 选项 2: 使用 CloudBase MySQL（生产环境）

1. 登录 CloudBase 控制台
2. 创建 MySQL 实例
3. 获取连接信息
4. 配置 `.env` 文件

## 🧪 测试覆盖

| 系统 | 测试脚本 | 测试数量 | 状态 |
|------|---------|---------|------|
| 绑定系统 | `test-binding-flow.js` | 11 | ✅ 就绪 |
| 导航任务 | `test-task-flow.js` | 18 | ✅ 就绪 |
| 位置共享 | 集成在导航任务测试中 | - | ✅ 就绪 |

## 📊 预期测试结果

### 绑定系统测试
```
🎉 所有测试通过！关系绑定系统工作正常。
```

### 导航任务系统测试
```
🎉 所有测试通过！导航任务系统工作正常。
```

## 🐛 故障排查

### 服务启动失败

**问题**: `数据库未配置，数据库功能不可用`

**解决**: 配置 MySQL 并设置 `.env` 文件

### 测试失败

**问题**: 连接被拒绝

**解决**: 
1. 确保服务在 `localhost:3000` 运行
2. 检查防火墙设置
3. 查看服务启动日志

### 数据库连接失败

**问题**: `MySQL 数据库连接失败`

**解决**:
```bash
# 测试 MySQL 是否可连接
mysql -u root -p

# 检查 MySQL 服务状态
# Windows
net start MySQL80
```
