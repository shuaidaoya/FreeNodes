# 📊 自动统计功能说明

## 🎯 功能概述

为 FreeNodes 项目添加了自动同步时间和节点数量到 README.md 文档的功能，让用户能够直接在项目首页看到最新的同步状态和统计信息，并自动维护更新日志。

## ✨ 功能特性

### 📈 实时统计显示
- **最后更新时间**: 显示最近一次同步的 UTC 时间
- **节点总数**: 显示所有节点的总数量
- **YAML 节点**: 显示 YAML 格式文件中的节点数量
- **Base64 行数**: 显示 Base64 格式文件的行数
- **同步状态**: 显示当前的同步状态（准备中/已同步）

### 🔄 自动更新机制
- 每30分钟自动运行 GitHub Actions 工作流
- 自动统计各类文件中的节点数量
- 自动更新 README.md 中的实时统计区域
- 保持向后兼容，同时更新传统的更新日志表格

### 📝 更新日志自动同步
- **智能记录管理**: 自动在更新日志表格中添加同步记录
- **防重复机制**: 同一天内只保留最新的自动更新记录
- **详细信息**: 包含 YAML 节点数和 Base64 行数的详细统计
- **时间戳**: 精确到秒的同步时间记录

## 🛠️ 技术实现

### 1. README.md 结构修改

在 README.md 文件开头添加了实时统计区域：

```markdown
## 📊 实时统计

<!-- AUTO_STATS_START -->
| 📈 统计项目 | 📋 当前状态 |
|------------|------------|
| 🕐 **最后更新时间** | 等待首次同步... |
| 🌐 **节点总数** | 统计中... |
| 📄 **YAML 节点** | 统计中... |
| 📝 **Base64 行数** | 统计中... |
| 🔄 **同步状态** | 🟡 准备中 |

> 🤖 **自动更新**: 每30分钟自动同步最新节点数据  
> 📊 **实时统计**: 上述数据由 GitHub Actions 自动更新
<!-- AUTO_STATS_END -->
```

### 2. GitHub Actions 工作流增强

修改了 `.github/workflows/sync-gist.yml` 文件，添加了以下功能：

#### 📊 节点统计逻辑
```bash
# 统计节点数量
total_nodes=0

if [ -f "nodes/all.yaml" ]; then
  yaml_nodes=$(grep -c "server:" nodes/all.yaml 2>/dev/null || echo "0")
  total_nodes=$((total_nodes + yaml_nodes))
  echo "yaml_nodes=$yaml_nodes" >> $GITHUB_OUTPUT
fi

if [ -f "nodes/base64.txt" ]; then
  base64_lines=$(wc -l < nodes/base64.txt 2>/dev/null || echo "0")
  echo "base64_lines=$base64_lines" >> $GITHUB_OUTPUT
fi

echo "total_nodes=$total_nodes" >> $GITHUB_OUTPUT
```

#### 📝 README 更新逻辑
```bash
# 更新实时统计区域
current_date=$(date '+%Y-%m-%d %H:%M:%S')
current_utc=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
total_nodes="${{ steps.count.outputs.total_nodes }}"
yaml_nodes="${{ steps.count.outputs.yaml_nodes }}"
base64_lines="${{ steps.count.outputs.base64_lines }}"

# 使用 sed 更新 AUTO_STATS 区域内的统计信息
sed -i '/<!-- AUTO_STATS_START -->/,/<!-- AUTO_STATS_END -->/{
  s/| 🕐 \*\*最后更新时间\*\* | .* |/| 🕐 **最后更新时间** | '"$current_utc"' |/
  s/| 🌐 \*\*节点总数\*\* | .* |/| 🌐 **节点总数** | '"$total_nodes"' 个 |/
  s/| 📄 \*\*YAML 节点\*\* | .* |/| 📄 **YAML 节点** | '"$yaml_nodes"' 个 |/
  s/| 📝 \*\*Base64 行数\*\* | .* |/| 📝 **Base64 行数** | '"$base64_lines"' 行 |/
  s/| 🔄 \*\*同步状态\*\* | .* |/| 🔄 **同步状态** | 🟢 已同步 |/
}' README.md
```

## 🧪 测试功能

### 测试脚本
创建了以下测试脚本来验证功能：

1. **Linux/macOS**: `scripts/test-stats.sh`
2. **Windows**: `scripts/test-stats.ps1`

### 手动测试步骤

1. **运行测试脚本**:
   ```bash
   # Linux/macOS
   bash scripts/test-stats.sh
   
   # Windows PowerShell
   powershell -ExecutionPolicy Bypass -File scripts/test-stats.ps1
   ```

2. **检查更新结果**:
   - 查看 README.md 中的实时统计区域
   - 确认数据已正确更新
   - 验证格式和样式正确

3. **恢复原始文件**:
   ```bash
   mv README.md.backup README.md
   ```

## 📋 使用说明

### 🔍 查看实时统计
- 访问项目主页即可看到最新的统计信息
- 统计数据每30分钟自动更新一次
- 显示的时间为 UTC 时间

### 🛠️ 维护和监控
- 通过 GitHub Actions 页面监控同步状态
- 检查工作流运行日志了解详细信息
- 如有问题，可手动触发工作流

### ⚙️ 自定义配置
如需修改统计显示格式：

1. 编辑 README.md 中的 `AUTO_STATS` 区域
2. 修改 GitHub Actions 工作流中的 sed 替换规则
3. 确保注释标记 `<!-- AUTO_STATS_START -->` 和 `<!-- AUTO_STATS_END -->` 保持不变

## 🎉 效果展示

### 更新前
```
| 🕐 **最后更新时间** | 等待首次同步... |
| 🌐 **节点总数** | 统计中... |
| 📄 **YAML 节点** | 统计中... |
| 📝 **Base64 行数** | 统计中... |
| 🔄 **同步状态** | 🟡 准备中 |
```

### 更新后
```
| 🕐 **最后更新时间** | 2025-01-10 15:30:45 UTC |
| 🌐 **节点总数** | 150 个 |
| 📄 **YAML 节点** | 120 个 |
| 📝 **Base64 行数** | 30 行 |
| 🔄 **同步状态** | 🟢 已同步 |
```

## 🔧 故障排除

### 常见问题

1. **统计数据未更新**
   - 检查 GitHub Actions 是否正常运行
   - 确认工作流有足够的权限
   - 查看工作流日志了解错误信息

2. **格式显示异常**
   - 确认 README.md 编码为 UTF-8
   - 检查 `AUTO_STATS` 区域的注释标记是否完整
   - 验证表格格式是否正确

3. **时间显示错误**
   - 确认使用的是 UTC 时间
   - 检查日期格式化命令是否正确

### 调试方法

1. **查看工作流日志**:
   - 进入 GitHub Actions 页面
   - 选择最近的工作流运行
   - 查看详细的执行日志

2. **手动验证统计**:
   - 下载节点文件到本地
   - 手动统计节点数量
   - 对比自动统计结果

## 📚 相关文档

- [GitHub Actions 权限配置指南](./GITHUB_ACTIONS_SETUP.md)
- [自动化功能总结](./AUTOMATION_SUMMARY.md)
- [项目主 README](../../README.md)