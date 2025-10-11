#!/bin/bash

# =============================================================================
# 文件哈希检测模块
# 功能：检测远程Gist文件与本地文件的变化
# 作者：FreeNodes自动化脚本
# 版本：1.0.0
# =============================================================================

set -euo pipefail  # 严格模式：遇到错误立即退出

# 全局变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMP_DIR=""
GIST_BASE_URL="https://gist.githubusercontent.com/shuaidaoya/9e5cf2749c0ce79932dd9229d9b4162b/raw"
FILES=("all.yaml" "base64.txt" "history.yaml" "mihomo.yaml")

# 日志函数
log_info() {
    echo "ℹ️  [INFO] $1" >&2
}

log_success() {
    echo "✅ [SUCCESS] $1" >&2
}

log_warning() {
    echo "⚠️  [WARNING] $1" >&2
}

log_error() {
    echo "❌ [ERROR] $1" >&2
}

# 创建临时目录
create_temp_dir() {
    TEMP_DIR="$PROJECT_ROOT/temp_download_$(date +%s)"
    mkdir -p "$TEMP_DIR"
    log_info "创建临时目录: $TEMP_DIR"
}

# 清理临时目录
cleanup_temp_dir() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log_info "清理临时目录: $TEMP_DIR"
    fi
}

# 设置清理陷阱
trap cleanup_temp_dir EXIT

# 计算文件SHA256哈希值
calculate_hash() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "FILE_NOT_EXISTS"
        return 0
    fi
    
    # 使用sha256sum计算哈希，如果不可用则尝试其他方法
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | cut -d' ' -f1
    elif command -v openssl >/dev/null 2>&1; then
        openssl dgst -sha256 "$file" | cut -d' ' -f2
    else
        log_error "无法找到哈希计算工具 (sha256sum/shasum/openssl)"
        return 1
    fi
}

# 下载远程文件
download_remote_file() {
    local filename="$1"
    local url="$GIST_BASE_URL/$filename"
    local output_path="$TEMP_DIR/$filename"
    local max_retries=3
    local retry_count=0
    
    log_info "下载远程文件: $filename"
    
    while [ $retry_count -lt $max_retries ]; do
        if curl -fsSL --connect-timeout 30 --max-time 60 "$url" -o "$output_path"; then
            log_success "下载成功: $filename"
            return 0
        else
            retry_count=$((retry_count + 1))
            log_warning "下载失败 (尝试 $retry_count/$max_retries): $filename"
            
            if [ $retry_count -lt $max_retries ]; then
                log_info "等待 5 秒后重试..."
                sleep 5
            fi
        fi
    done
    
    log_error "下载最终失败: $filename"
    return 1
}

# 检测单个文件变化
detect_file_change() {
    local filename="$1"
    local remote_file="$TEMP_DIR/$filename"
    local local_file="$PROJECT_ROOT/nodes/$filename"
    
    # 下载远程文件
    if ! download_remote_file "$filename"; then
        log_error "无法下载远程文件: $filename"
        return 2  # 下载失败
    fi
    
    # 计算哈希值
    local remote_hash
    local local_hash
    
    remote_hash=$(calculate_hash "$remote_file")
    if [ $? -ne 0 ]; then
        log_error "计算远程文件哈希失败: $filename"
        return 3  # 哈希计算失败
    fi
    
    local_hash=$(calculate_hash "$local_file")
    if [ $? -ne 0 ]; then
        log_error "计算本地文件哈希失败: $filename"
        return 3  # 哈希计算失败
    fi
    
    # 输出哈希值用于调试
    log_info "$filename - 远程哈希: ${remote_hash:0:16}..."
    log_info "$filename - 本地哈希: ${local_hash:0:16}..."
    
    # 比较哈希值
    if [ "$remote_hash" != "$local_hash" ]; then
        log_success "$filename 检测到变化"
        return 0  # 有变化
    else
        log_info "$filename 无变化"
        return 1  # 无变化
    fi
}

# 检测所有文件变化
detect_all_changes() {
    local changed_files=()
    local failed_files=()
    local unchanged_files=()
    
    log_info "开始检测所有文件变化..."
    
    for file in "${FILES[@]}"; do
        log_info "检测文件: $file"
        
        case $(detect_file_change "$file"; echo $?) in
            0)
                changed_files+=("$file")
                log_success "✓ $file: 有变化"
                ;;
            1)
                unchanged_files+=("$file")
                log_info "○ $file: 无变化"
                ;;
            *)
                failed_files+=("$file")
                log_error "✗ $file: 检测失败"
                ;;
        esac
    done
    
    # 输出检测结果摘要
    echo ""
    log_info "=== 检测结果摘要 ==="
    log_info "总文件数: ${#FILES[@]}"
    log_success "有变化: ${#changed_files[@]} 个文件"
    log_info "无变化: ${#unchanged_files[@]} 个文件"
    
    if [ ${#failed_files[@]} -gt 0 ]; then
        log_error "检测失败: ${#failed_files[@]} 个文件"
        log_error "失败文件: ${failed_files[*]}"
    fi
    
    # 输出变化文件列表（供后续脚本使用）
    if [ ${#changed_files[@]} -gt 0 ]; then
        echo ""
        log_success "变化文件列表:"
        for file in "${changed_files[@]}"; do
            echo "$file"
        done
        
        # 设置GitHub Actions输出
        if [ -n "${GITHUB_OUTPUT:-}" ]; then
            echo "has_changes=true" >> "$GITHUB_OUTPUT"
            echo "changed_files=${changed_files[*]}" >> "$GITHUB_OUTPUT"
        fi
        
        return 0  # 有文件变化
    else
        echo ""
        log_info "所有文件均无变化"
        
        # 设置GitHub Actions输出
        if [ -n "${GITHUB_OUTPUT:-}" ]; then
            echo "has_changes=false" >> "$GITHUB_OUTPUT"
            echo "changed_files=" >> "$GITHUB_OUTPUT"
        fi
        
        return 1  # 无文件变化
    fi
}

# 主函数
main() {
    log_info "=== 文件哈希检测模块启动 ==="
    log_info "项目根目录: $PROJECT_ROOT"
    log_info "Gist基础URL: $GIST_BASE_URL"
    log_info "检测文件: ${FILES[*]}"
    
    # 创建临时目录
    create_temp_dir
    
    # 确保nodes目录存在
    mkdir -p "$PROJECT_ROOT/nodes"
    
    # 检测所有文件变化
    if detect_all_changes; then
        log_success "=== 检测完成：发现文件变化 ==="
        exit 0
    else
        log_info "=== 检测完成：无文件变化 ==="
        exit 1
    fi
}

# 如果脚本被直接执行（而非被source），则运行主函数
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi