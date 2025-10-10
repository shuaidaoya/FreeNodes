#!/bin/bash

# FreeNodes - 节点同步脚本
# 用于手动同步Gist中的节点文件到本地仓库

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Gist配置
GIST_BASE_URL="https://gist.githubusercontent.com/shuaidaoya/9e5cf2749c0ce79932dd9229d9b4162b/raw/45a4616a347cf5998fd9ef83d41d8a91ff314bc6"
NODES_DIR="nodes"

# 文件列表
declare -A FILES=(
    ["all.yaml"]="完整 YAML 配置"
    ["base64.txt"]="Base64 编码列表"
    ["history.yaml"]="历史节点记录"
    ["mihomo.yaml"]="Mihomo 专用配置"
)

# 创建节点目录
create_nodes_directory() {
    log_info "创建节点目录..."
    mkdir -p "$NODES_DIR"
    log_success "节点目录创建完成: $NODES_DIR"
}

# 下载单个文件
download_file() {
    local filename="$1"
    local description="$2"
    local url="${GIST_BASE_URL}/${filename}"
    local output_path="${NODES_DIR}/${filename}"
    
    log_info "正在下载 ${filename} (${description})..."
    
    if curl -fsSL "$url" -o "$output_path"; then
        local file_size=$(ls -lh "$output_path" | awk '{print $5}')
        log_success "✅ ${filename} 下载成功 (${file_size})"
        return 0
    else
        log_error "❌ ${filename} 下载失败"
        return 1
    fi
}

# 下载所有文件
download_all_files() {
    log_info "开始下载所有节点文件..."
    local success_count=0
    local total_count=${#FILES[@]}
    
    for filename in "${!FILES[@]}"; do
        if download_file "$filename" "${FILES[$filename]}"; then
            ((success_count++))
        fi
    done
    
    log_info "下载完成: ${success_count}/${total_count} 个文件成功"
    
    if [ $success_count -eq $total_count ]; then
        log_success "🎉 所有文件下载成功！"
    elif [ $success_count -gt 0 ]; then
        log_warning "⚠️ 部分文件下载成功"
    else
        log_error "💥 所有文件下载失败"
        exit 1
    fi
}

# 统计节点数量
count_nodes() {
    log_info "统计节点数量..."
    local total_nodes=0
    
    # 统计 YAML 文件中的节点
    if [ -f "${NODES_DIR}/all.yaml" ]; then
        local yaml_nodes=$(grep -c "server:" "${NODES_DIR}/all.yaml" 2>/dev/null || echo "0")
        total_nodes=$((total_nodes + yaml_nodes))
        log_info "YAML 格式节点: ${yaml_nodes} 个"
    fi
    
    # 统计 Base64 文件行数
    if [ -f "${NODES_DIR}/base64.txt" ]; then
        local base64_lines=$(wc -l < "${NODES_DIR}/base64.txt" 2>/dev/null || echo "0")
        log_info "Base64 格式行数: ${base64_lines} 行"
    fi
    
    log_success "📊 总计节点数量: ${total_nodes} 个"
    echo "$total_nodes"
}

# 生成文件信息
generate_file_info() {
    log_info "生成文件信息..."
    local readme_file="${NODES_DIR}/README.md"
    
    cat > "$readme_file" << EOF
# 📊 节点文件信息

**更新时间**: $(date '+%Y-%m-%d %H:%M:%S %Z')

| 文件名 | 描述 | 大小 | 最后修改 |
|--------|------|------|----------|
EOF

    for filename in "${!FILES[@]}"; do
        local file_path="${NODES_DIR}/${filename}"
        if [ -f "$file_path" ]; then
            local description="${FILES[$filename]}"
            local file_size=$(ls -lh "$file_path" | awk '{print $5}')
            local modified=$(date -r "$file_path" '+%Y-%m-%d %H:%M')
            echo "| $filename | $description | $file_size | $modified |" >> "$readme_file"
        fi
    done
    
    cat >> "$readme_file" << EOF

## 📋 使用说明

这些文件是从 Gist 自动同步的最新节点配置：

- **all.yaml**: 适用于 V2Ray、Clash、Shadowrocket 等客户端
- **base64.txt**: 通用 Base64 编码格式，适用于大多数客户端
- **history.yaml**: 历史节点备份，可用作备用选择
- **mihomo.yaml**: 专为 Mihomo 客户端优化的配置

> 🔄 文件每日自动更新，确保节点的新鲜度和可用性
> 
> 📡 订阅链接请参考主 README.md 文件
EOF

    log_success "文件信息生成完成: $readme_file"
}

# 验证文件完整性
validate_files() {
    log_info "验证文件完整性..."
    local valid_count=0
    
    for filename in "${!FILES[@]}"; do
        local file_path="${NODES_DIR}/${filename}"
        if [ -f "$file_path" ] && [ -s "$file_path" ]; then
            log_success "✅ ${filename} - 文件有效"
            ((valid_count++))
        else
            log_error "❌ ${filename} - 文件无效或为空"
        fi
    done
    
    log_info "文件验证完成: ${valid_count}/${#FILES[@]} 个文件有效"
}

# 主函数
main() {
    echo "🚀 FreeNodes 节点同步脚本"
    echo "================================"
    
    # 检查依赖
    if ! command -v curl &> /dev/null; then
        log_error "curl 命令未找到，请先安装 curl"
        exit 1
    fi
    
    # 执行同步流程
    create_nodes_directory
    download_all_files
    local node_count=$(count_nodes)
    generate_file_info
    validate_files
    
    echo "================================"
    log_success "🎉 节点同步完成！"
    log_info "📊 节点总数: ${node_count} 个"
    log_info "📁 文件位置: ${NODES_DIR}/"
    echo "================================"
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi