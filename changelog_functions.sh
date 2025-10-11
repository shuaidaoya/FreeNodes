#!/bin/bash

# README更新日志处理函数
# 用于修复更新日志覆盖问题

# 配置参数
MAX_CHANGELOG_RECORDS=10

# 函数：添加新的更新日志记录
# 参数：$1=时间, $2=节点摘要, $3=节点详情, $4=README文件路径
add_changelog_entry() {
    local current_date="$1"
    local node_summary="$2"
    local node_details="$3"
    local readme_file="$4"
    
    echo "🔍 添加新的更新日志记录: $current_date"
    
    # 参数验证
    if [[ -z "$current_date" || -z "$node_summary" || -z "$node_details" || -z "$readme_file" ]]; then
        echo "❌ 参数不完整，跳过更新日志添加"
        return 1
    fi
    
    # 文件存在性检查
    if [[ ! -f "$readme_file" ]]; then
        echo "❌ README文件不存在: $readme_file"
        return 1
    fi
    
    # 检查表格结构是否存在
    if ! grep -q "|------|------|----------|" "$readme_file"; then
        echo "❌ 更新日志表格结构不存在"
        return 2
    fi
    
    # 添加新记录到表格头部（在分隔符行后）
    sed -i '/|------|------|----------|/a\| '"$current_date"' | '"$node_summary"' | '"$node_details"' |' "$readme_file"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ 新记录添加成功"
        return 0
    else
        echo "❌ 新记录添加失败"
        return 3
    fi
}

# 函数：清理超出限制的旧记录
# 参数：$1=README文件路径, $2=最大记录数（可选，默认10）
cleanup_old_records() {
    local readme_file="$1"
    local max_records="${2:-$MAX_CHANGELOG_RECORDS}"
    
    echo "🔍 清理超出限制的旧记录，保留最近 $max_records 条"
    
    # 参数验证
    if [[ -z "$readme_file" ]]; then
        echo "❌ README文件路径未指定"
        return 1
    fi
    
    if [[ ! -f "$readme_file" ]]; then
        echo "❌ README文件不存在: $readme_file"
        return 1
    fi
    
    # 验证max_records是正整数
    if ! [[ "$max_records" =~ ^[1-9][0-9]*$ ]]; then
        echo "❌ 最大记录数必须是正整数: $max_records"
        return 2
    fi
    
    # 使用awk处理记录限制
    awk -v max_records="$max_records" '
    BEGIN { 
        in_changelog = 0
        record_count = 0 
    }
    
    # 检测更新日志开始
    /## 📋 更新日志/ { 
        in_changelog = 1
        print
        next 
    }
    
    # 检测更新日志结束（下一个章节开始）
    /^## / && in_changelog && !/## 📋 更新日志/ { 
        in_changelog = 0 
    }
    
    # 处理更新日志区域内的记录
    in_changelog && /^\|.*\|.*\|.*\|$/ && !/^|.*---|.*---|.*|$/ && !/时间.*节点数量.*节点详情/ {
        record_count++
        if (record_count <= max_records) {
            print
        } else {
            # 跳过超出限制的记录
        }
        next
    }
    
    # 其他行直接输出
    { print }
    ' "$readme_file" > "${readme_file}.tmp"
    
    # 检查awk处理是否成功
    if [[ $? -eq 0 && -f "${readme_file}.tmp" ]]; then
        # 检查临时文件是否为空
        if [[ -s "${readme_file}.tmp" ]]; then
            mv "${readme_file}.tmp" "$readme_file"
            echo "✅ 记录清理完成，保留了最近 $max_records 条记录"
            return 0
        else
            echo "❌ 临时文件为空，清理失败"
            rm -f "${readme_file}.tmp"
            return 3
        fi
    else
        echo "❌ awk处理失败"
        rm -f "${readme_file}.tmp"
        return 3
    fi
}

# 函数：完整的更新日志更新流程
# 参数：$1=时间, $2=节点摘要, $3=节点详情, $4=README文件路径
update_changelog() {
    local current_date="$1"
    local node_summary="$2"
    local node_details="$3"
    local readme_file="$4"
    
    echo "🚀 开始更新日志更新流程"
    
    # 备份README文件
    if [[ -f "$readme_file" ]]; then
        cp "$readme_file" "${readme_file}.changelog_backup"
        echo "✅ 已备份README文件"
    fi
    
    # 添加新记录
    if add_changelog_entry "$current_date" "$node_summary" "$node_details" "$readme_file"; then
        echo "✅ 新记录添加成功"
    else
        echo "❌ 新记录添加失败，恢复备份"
        if [[ -f "${readme_file}.changelog_backup" ]]; then
            cp "${readme_file}.changelog_backup" "$readme_file"
        fi
        return 1
    fi
    
    # 清理旧记录
    if cleanup_old_records "$readme_file"; then
        echo "✅ 旧记录清理成功"
    else
        echo "❌ 旧记录清理失败，恢复备份"
        if [[ -f "${readme_file}.changelog_backup" ]]; then
            cp "${readme_file}.changelog_backup" "$readme_file"
        fi
        return 2
    fi
    
    # 验证更新结果
    if grep -q "| $current_date.*|" "$readme_file"; then
        echo "✅ 更新日志更新完成"
        # 清理备份文件
        rm -f "${readme_file}.changelog_backup"
        return 0
    else
        echo "❌ 更新验证失败，恢复备份"
        if [[ -f "${readme_file}.changelog_backup" ]]; then
            cp "${readme_file}.changelog_backup" "$readme_file"
        fi
        return 3
    fi
}

# 导出函数供外部使用
export -f add_changelog_entry
export -f cleanup_old_records  
export -f update_changelog