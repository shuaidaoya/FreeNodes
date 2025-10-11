# README统计功能集成测试脚本
Write-Host "开始README统计功能集成测试..." -ForegroundColor Green

# 测试Base64节点统计
Write-Host "`n测试Base64节点统计..." -ForegroundColor Yellow
$base64Count = 0
if (Test-Path "nodes/base64.txt") {
    try {
        $content = Get-Content nodes/base64.txt -Raw
        $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($content))
        $lines = $decoded -split "`n"
        $base64Count = ($lines | Where-Object { $_ -match "^(vmess|vless|trojan|ss|ssr)://" }).Count
        Write-Host "Base64节点统计: $base64Count 个" -ForegroundColor Green
    }
    catch {
        Write-Host "Base64解码失败: $($_.Exception.Message)" -ForegroundColor Red
        $base64Count = 0
    }
}
else {
    Write-Host "base64.txt 文件不存在" -ForegroundColor Yellow
    $base64Count = 0
}

# 测试YAML节点统计
Write-Host "`n测试YAML节点统计..." -ForegroundColor Yellow
$yamlCount = 0
if (Test-Path "nodes/all.yaml") {
    $yamlCount = (Get-Content nodes/all.yaml | Where-Object { $_ -match "server:" }).Count
    Write-Host "YAML节点统计: $yamlCount 个" -ForegroundColor Green
}
else {
    Write-Host "all.yaml 文件不存在" -ForegroundColor Yellow
    $yamlCount = 0
}

# 计算总节点数
$totalNodes = $yamlCount + $base64Count
Write-Host "`n总节点统计: $totalNodes 个 (YAML: $yamlCount, Base64: $base64Count)" -ForegroundColor Cyan

# 测试README.md统计区域
Write-Host "`n测试README.md统计区域..." -ForegroundColor Yellow
if (Test-Path "README.md") {
    $readmeContent = Get-Content README.md -Raw
    
    # 检查AUTO_STATS区域
    if ($readmeContent -match "AUTO_STATS_START") {
        Write-Host "找到AUTO_STATS区域" -ForegroundColor Green
    }
    else {
        Write-Host "未找到AUTO_STATS区域" -ForegroundColor Red
    }
    
    # 检查更新日志表格
    if ($readmeContent -match "更新日志") {
        Write-Host "找到更新日志表格" -ForegroundColor Green
    }
    else {
        Write-Host "未找到更新日志表格" -ForegroundColor Red
    }
}
else {
    Write-Host "README.md 文件不存在" -ForegroundColor Red
}

# 生成测试报告
Write-Host "`n测试报告:" -ForegroundColor Green
Write-Host "==========================================="
Write-Host "Base64节点统计: $base64Count 个"
Write-Host "YAML节点统计: $yamlCount 个"
Write-Host "总节点数: $totalNodes 个"
Write-Host "==========================================="

# 验证修复效果
Write-Host "`n验证修复效果:" -ForegroundColor Yellow
if ($base64Count -gt 0) {
    Write-Host "Base64统计修复成功 - 不再显示为0" -ForegroundColor Green
}
else {
    Write-Host "Base64统计仍为0，可能需要进一步检查" -ForegroundColor Yellow
}

if ($totalNodes -gt 0) {
    Write-Host "总节点统计正常" -ForegroundColor Green
}
else {
    Write-Host "总节点统计异常" -ForegroundColor Red
}

Write-Host "`nREADME统计功能集成测试完成!" -ForegroundColor Green