# 亲途 (Qintu)

一款帮助不便使用传统导航软件的人群轻松使用导航功能的 Flutter 应用。

## 设计理念

- 统一界面，不区分"发送者"和"接收者"角色
- 顶部 Tab 架构：路线规划 / 关系绑定 / 设置
- 双向对等绑定，确认后双方自动互相绑定

## 项目结构

```
qintu/
├── lib/                    # Flutter 代码
│   ├── features/           # 功能模块
│   ├── core/http/         # HTTP 客户端
│   ├── models/            # 数据模型
│   ├── providers/         # 状态管理
│   └── ...
├── functions/qintu-api/   # 云函数（后端）
├── database/              # 数据库脚本
└── docs/                  # 开发文档
```

## 技术栈

| 类别 | 技术 |
|------|------|
| 前端 | Flutter + Provider + GoRouter |
| 网络 | Dio |
| 后端 | Node.js + Express + MySQL |
| 云平台 | CloudBase |
| 地图 | 高德 Android SDK |

## 文档导航

| 文档 | 说明 |
|------|------|
| CLAUDE.md | 开发规则（每次对话自动加载） |
| docs/CHECKLIST.md | 上线前检查 |
| docs/guides/API_CONTRACT.md | 接口规范 |
| docs/guides/AMAP_GUIDE.md | 高德地图集成 |
| docs/operations/DEPLOY_GUIDE.md | 部署指南 |
| docs/features/map_navigation/ | 地图导航功能文档 |
