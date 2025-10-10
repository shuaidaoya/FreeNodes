# 测试 README 统计更新功能
Write-Host "🧪 测试 README 统计更新功能..." -ForegroundColor Cyan

# 模拟统计数据
$current_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss UTC")
$total_nodes = "150"
$yaml_nodes = "120"
$base64_lines = "30"

Write-Host "📊 模拟统计数据:" -ForegroundColor Yellow
Write-Host "  - 更新时间: $current_utc"
Write-Host "  - 节点总数: $total_nodes"
Write-Host "  - YAML 节点: $yaml_nodes"
Write-Host "  - Base64 行数: $base64_lines"

# 备份原始 README
if (Test-Path "README.md") {
    Copy-Item "README.md" "README.md.backup"
    Write-Host "💾 已备份原始 README.md" -ForegroundColor Green
} else {
    Write-Host "❌ README.md 文件不存在" -ForegroundColor Red
    exit 1
}

# 读取并更新 README 内容
try {
    $content = Get-Content "README.md" -Raw -Encoding UTF8
    
    # 更新实时统计区域
    $content = $content -replace '\| 🕐 \*\*最后更新时间\*\* \| .* \|', "| 🕐 **最后更新时间** | $current_utc |"
    $content = $content -replace '\| 🌐 \*\*节点总数\*\* \| .* \|', "| 🌐 **节点总数** | $total_nodes 个 |"
    $content = $content -replace '\| 📄 \*\*YAML 节点\*\* \| .* \|', "| 📄 **YAML 节点** | $yaml_nodes 个 |"
    $content = $content -replace '\| 📝 \*\*Base64 行数\*\* \| .* \|', "| 📝 **Base64 行数** | $base64_lines 行 |"
    $content = $content -replace '\| 🔄 \*\*同步状态\*\* \| .* \|', "| 🔄 **同步状态** | 🟢 已同步 |"
    
    # 保存更新后的内容
    $content | Set-Content "README.md" -Encoding UTF8
    
    Write-Host "✅ README.md 实时统计已更新" -ForegroundColor Green
    
    # 显示更新后的统计区域
    Write-Host "`n📋 更新后的统计区域:" -ForegroundColor Cyan
    $lines = Get-Content "README.md" -Encoding UTF8
    $inStatsSection = $false
    foreach ($line in $lines) {
        if ($line -match "<!-- AUTO_STATS_START -->") {
            $inStatsSection = $true
        }
        if ($inStatsSection) {
            Write-Host $line
        }
        if ($line -match "<!-- AUTO_STATS_END -->") {
            break
        }
    }
    
    Write-Host "`n🔄 要恢复原始文件，请运行: Move-Item README.md.backup README.md" -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ 更新失败: $($_.Exception.Message)" -ForegroundColor Red
}