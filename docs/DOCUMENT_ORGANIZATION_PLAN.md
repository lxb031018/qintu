# 文档整理计划

## 📊 当前文档分布

### 根目录下的文档（需要整理）

| 文件 | 内容类型 | 建议位置 | 操作 |
|------|---------|---------|------|
| `ARCHITECTURE_OPTIMIZATION.md` | 架构总结 | `docs/ARCHITECTURE_OPTIMIZATION.md` | 移动 |
| `DEPLOY_STEPS.md` | 部署步骤 | `docs/DEPLOY_STEPS.md` | 移动 |
| `project.md` | 项目说明 | 合并到 `README_PROJECT.md` | 合并后删除 |
| `README_PROJECT.md` | 项目总览 | 保留根目录（入口文档） | ✅ 保留 |
| `TROUBLESHOOTING.md` | 故障排查 | `docs/TROUBLESHOOTING.md` | 移动 |
| `README.md` | 项目简介（旧版） | 合并到 `README_PROJECT.md` | 合并后删除 |

### docs/ 目录（已整理）

已有 15 个文档，结构清晰，分类合理。✅

---

## 🎯 整理方案

### 方案 A：完全统一（推荐）⭐

**原则**：
- 根目录只保留 **1-2 个入口文档**
- 所有技术文档统一在 `docs/` 目录
- 避免文档重复

**根目录保留**：
```
qintu/
├── README.md                    # 项目简介（精简版）
├── README_PROJECT.md            # 项目总览（完整版，可改名）
└── docs/                        # 所有技术文档
    └── README.md                # 文档索引
```

**移动操作**：
1. `ARCHITECTURE_OPTIMIZATION.md` → `docs/`
2. `DEPLOY_STEPS.md` → `docs/`
3. `TROUBLESHOOTING.md` → `docs/`
4. `project.md` → 合并到 `README_PROJECT.md`
5. `README.md` → 合并到 `README_PROJECT.md`

### 方案 B：部分保留

**原则**：
- 常用文档保留在根目录
- 详细技术文档放在 `docs/`

**根目录保留**：
- `README.md` - 项目简介
- `DEPLOY_STEPS.md` - 快速部署（常用）
- `TROUBLESHOOTING.md` - 故障排查（常用）
- `docs/` - 详细技术文档

---

## 📝 推荐操作

我建议执行 **方案 A（完全统一）**：

1. **移动文档到 docs/**
   ```bash
   mv ARCHITECTURE_OPTIMIZATION.md docs/
   mv DEPLOY_STEPS.md docs/
   mv TROUBLESHOOTING.md docs/
   ```

2. **合并重复内容**
   - 将 `project.md` 内容合并到 `README_PROJECT.md`
   - 将 `README.md` 内容合并到 `README_PROJECT.md`

3. **更新文档索引**
   - 更新 `docs/README.md` 添加新移动的文档
   - 更新 `README_PROJECT.md` 中的文档链接

4. **删除重复文档**
   - 删除 `project.md`
   - 删除 `README.md`（或改为指向 README_PROJECT.md 的快捷方式）

---

**是否执行方案 A？** 我可以帮你自动完成所有移动和更新操作。
