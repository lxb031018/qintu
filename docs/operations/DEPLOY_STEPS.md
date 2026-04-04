# 亲途云函数部署步骤

## ✅ 准备工作已完成

- [x] 云函数代码已测试通过
- [x] 依赖已安装
- [x] 已打包为 zip 文件

**打包文件位置**：`D:\AllCodes\qintu\functions\qintu-api.zip`

---

## 📋 部署步骤

### 第一步：上传云函数

1. 打开 [CloudBase 控制台](https://tcb.cloud.tencent.com/)
2. 选择环境：`qintu-cloudebase-5f5bpuj13bc6467`
3. 点击左侧菜单：**云函数**
4. 点击：**新建云函数**
5. 填写信息：
   - **函数名称**：`qintu-api`
   - **运行环境**：`Nodejs 16.13`
   - **超时时间**：`30 秒`
   - **内存**：`512 MB`
6. 点击：**创建**

### 第二步：上传代码

1. 创建完成后，进入函数详情页
2. 点击：**函数代码**
3. 选择：**本地上传zip**
4. 选择文件：`D:\AllCodes\qintu\functions\qintu-api.zip`
5. 点击：**上传**
6. 等待上传完成

### 第三步：配置环境变量

在函数配置页面，添加以下环境变量：

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `ENV_ID` | `qintu-cloudebase-5f5bpuj13bc6467` | CloudBase 环境 ID |
| `DB_HOST` | `<从控制台获取>` | MySQL 主机地址 |
| `DB_PORT` | `3306` | MySQL 端口 |
| `DB_USER` | `<从控制台获取>` | 数据库用户名 |
| `DB_PASSWORD` | `<从控制台获取>` | 数据库密码 |
| `DB_NAME` | `qintu` | 数据库名称 |
| `NODE_ENV` | `production` | 运行环境 |

**如何获取 MySQL 连接信息**：
1. CloudBase 控制台 → **MySQL 数据库**
2. 点击 **连接信息**
3. 复制主机地址、端口、用户名

### 第四步：创建 HTTP 访问

1. 云函数详情页 → **触发管理** 或 **HTTP 访问**
2. 点击：**创建 HTTP 访问**
3. 填写：
   - **访问路径**：`/qintu-api`
   - **请求方法**：`ALL`
4. 点击：**确定**
5. 保存生成的访问地址

### 第五步：测试部署

使用浏览器或 curl 测试：

```bash
curl https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/health
```

**预期响应**：
```json
{
  "status": "ok",
  "timestamp": "2026-04-04T10:00:00.000Z",
  "service": "qintu-api"
}
```

---

## 🗄️ 数据库初始化

### 执行建表脚本

1. CloudBase 控制台 → **MySQL 数据库**
2. 点击：**SQL 查询** 或 **在线 SQL 编辑器**
3. 打开文件：`D:\AllCodes\qintu\database\init_schema.sql`
4. 复制全部内容
5. 粘贴到 SQL 编辑器
6. 点击：**执行**
7. 等待执行完成

### 验证表创建成功

```sql
SHOW TABLES;
-- 应该看到 5 个表：
-- users
-- user_bindings
-- navigation_tasks
-- real_time_locations
-- operation_logs
```

---

## ✅ 部署检查清单

部署完成后，确认以下项目：

- [ ] 云函数状态为"已部署"
- [ ] 环境变量配置正确
- [ ] HTTP 访问路径已创建
- [ ] 健康检查接口返回正常
- [ ] 数据库表全部创建成功
- [ ] 测试用户注册接口正常
- [ ] 测试绑定码生成接口正常

---

## 🎉 部署完成

部署成功后，您将获得：

✅ 完整的后端 API 服务（21 个接口）  
✅ MySQL 数据库（5 张表 + 2 个视图）  
✅ 绑定人数限制功能  
✅ 完整的错误处理和日志记录  

---

**部署日期**：2026-04-04  
**云函数版本**：v1.0.0  
**环境 ID**：`qintu-cloudebase-5f5bpuj13bc6467`
