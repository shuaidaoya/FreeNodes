#!/bin/bash

# 测试 README 统计更新功能
echo "🧪 测试 README 统计更新功能..."

# 模拟统计数据
current_date=$(date '+%Y-%m-%d %H:%M:%S')
current_utc=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
total_nodes="150"
yaml_nodes="120"
base64_lines="30"

echo "📊 模拟统计数据:"
echo "  - 更新时间: $current_utc"
echo "  - 节点总数: $total_nodes"
echo "  - YAML 节点: $yaml_nodes"
echo "  - Base64 行数: $base64_lines"

# 备份原始 README
cp README.md README.md.backup
echo "💾 已备份原始 README.md"

# 更新实时统计区域
if [ -f "README.md" ]; then
  # 使用 sed 更新 AUTO_STATS 区域内的统计信息
  sed -i '/<!-- AUTO_STATS_START -->/,/<!-- AUTO_STATS_END -->/{
    s/| 🕐 \*\*最后更新时间\*\* | .* |/| 🕐 **最后更新时间** | '"$current_utc"' |/
    s/| 🌐 \*\*节点总数\*\* | .* |/| 🌐 **节点总数** | '"$total_nodes"' 个 |/
    s/| 📄 \*\*YAML 节点\*\* | .* |/| 📄 **YAML 节点** | '"$yaml_nodes"' 个 |/
    s/| 📝 \*\*Base64 行数\*\* | .* |/| 📝 **Base64 行数** | '"$base64_lines"' 行 |/
    s/| 🔄 \*\*同步状态\*\* | .* |/| 🔄 **同步状态** | 🟢 已同步 |/
  }' README.md
  
  echo "✅ README.md 实时统计已更新"
  
  # 显示更新后的统计区域
  echo ""
  echo "📋 更新后的统计区域:"
  sed -n '/<!-- AUTO_STATS_START -->/,/<!-- AUTO_STATS_END -->/p' README.md
  
  echo ""
  echo "🔄 要恢复原始文件，请运行: mv README.md.backup README.md"
else
  echo "❌ README.md 文件不存在"
fi