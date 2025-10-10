#!/bin/bash

# 测试更新日志自动添加功能
echo "🧪 测试更新日志自动添加功能..."

# 模拟统计数据
current_date=$(date '+%Y-%m-%d %H:%M:%S')
today_date=$(date '+%Y-%m-%d')
total_nodes="150"
yaml_nodes="120"
base64_lines="30"

echo "📊 模拟统计数据:"
echo "  - 当前时间: $current_date"
echo "  - 今日日期: $today_date"
echo "  - 节点总数: $total_nodes"
echo "  - YAML 节点: $yaml_nodes"
echo "  - Base64 行数: $base64_lines"

# 备份原始 README
cp README.md README.md.backup
echo "💾 已备份原始 README.md"

# 生成节点详情描述
node_details="📊 自动更新"
if [ "$yaml_nodes" -gt 0 ] && [ "$base64_lines" -gt 0 ]; then
  node_details="📊 自动更新 - YAML:${yaml_nodes}个 Base64:${base64_lines}行"
elif [ "$yaml_nodes" -gt 0 ]; then
  node_details="📊 自动更新 - YAML节点:${yaml_nodes}个"
elif [ "$base64_lines" -gt 0 ]; then
  node_details="📊 自动更新 - Base64:${base64_lines}行"
fi

echo "📝 生成的节点详情: $node_details"

# 检查是否已存在今天的自动更新记录
if ! grep -q "| $today_date.*📊 自动更新" README.md; then
  echo "➕ 今天还没有自动更新记录，将添加新记录"
  
  # 在表格头部后面插入新记录
  sed -i '/|------|------|----------|/a\| '"$current_date"' | '"$total_nodes"'个节点 | '"$node_details"' |' README.md
  echo "✅ 已添加新的更新日志记录: $current_date - $total_nodes 个节点"
else
  echo "🔄 今天已有自动更新记录，将更新现有记录"
  
  # 更新现有记录
  sed -i "s/| $today_date.*| [^|]* | .*📊 自动更新.* |/| $current_date | ${total_nodes}个节点 | $node_details |/" README.md
  echo "✅ 已更新今天的更新日志记录"
fi

echo ""
echo "📋 更新后的更新日志表格:"
echo "----------------------------------------"
# 显示更新日志表格
sed -n '/## 📋 更新日志/,/>/p' README.md | head -10

echo ""
echo "🔄 要恢复原始文件，请运行: mv README.md.backup README.md"
echo "📖 要查看完整差异，请运行: diff README.md.backup README.md"