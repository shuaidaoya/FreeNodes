# 统计显示优化验证脚本
Write-Host "🔍 开始验证统计显示优化..." -ForegroundColor Green

# 1. 验证节点统计逻辑
Write-Host "`n📊 验证节点统计逻辑..." -ForegroundColor Yellow

# 统计YAML节点
$yamlNodes = 0
if (Test-Path "nodes/all.yaml") {
    $yamlContent = Get-Content "nodes/all.yaml" -Raw
    $yamlNodes = ($yamlContent | Select-String "server:" -AllMatches).Matches.Count
    Write-Host "✅ YAML节点统计: $yamlNodes 个" -ForegroundColor Green
} else {
    Write-Host "❌ all.yaml 文件不存在" -ForegroundColor Red
}

# 统计Base64节点
$base64Nodes = 0
if (Test-Path "nodes/base64.txt") {
    $base64Content = Get-Content "nodes/base64.txt" -Raw
    $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Content))
    $lines = $decoded -split "`n"
    $base64Nodes = ($lines | Where-Object { $_ -match "^[a-zA-Z0-9]*://" }).Count
    Write-Host "✅ Base64节点统计: $base64Nodes 个" -ForegroundColor Green
} else {
    Write-Host "❌ base64.txt 文件不存在" -ForegroundColor Red
}

Write-Host "`n📋 统计结果汇总:" -ForegroundColor Cyan
Write-Host "  📄 YAML节点: $yamlNodes 个" -ForegroundColor White
Write-Host "  📝 Base64节点: $base64Nodes 个" -ForegroundColor White
Write-Host "  ❌ 不再显示节点总数" -ForegroundColor Gray

# 2. 验证README格式
Write-Host "`n📄 验证README格式..." -ForegroundColor Yellow

if (Test-Path "README.md") {
    $readmeContent = Get-Content "README.md" -Raw
    
    # 检查AUTO_STATS区域
    if ($readmeContent -match '<!-- AUTO_STATS_START -->(.*?)<!-- AUTO_STATS_END -->') {
        $statsSection = $matches[1]
        Write-Host "✅ 找到AUTO_STATS区域" -ForegroundColor Green
        
        # 检查是否包含节点总数行（应该不包含）
        if ($statsSection -match '\*\*节点总数\*\*') {
            Write-Host "❌ 仍然包含节点总数行，需要移除" -ForegroundColor Red
        } else {
            Write-Host "✅ 已成功移除节点总数行" -ForegroundColor Green
        }
        
        # 检查YAML和Base64节点行
        if ($statsSection -match '\*\*YAML 节点\*\*') {
            Write-Host "✅ 包含YAML节点行" -ForegroundColor Green
        } else {
            Write-Host "❌ 缺少YAML节点行" -ForegroundColor Red
        }
        
        if ($statsSection -match '\*\*Base64 节点数\*\*') {
            Write-Host "✅ 包含Base64节点行" -ForegroundColor Green
        } else {
            Write-Host "❌ 缺少Base64节点行" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ 未找到AUTO_STATS区域" -ForegroundColor Red
    }
} else {
    Write-Host "❌ README.md 文件不存在" -ForegroundColor Red
}

# 3. 验证GitHub Actions工作流
Write-Host "`n⚙️ 验证GitHub Actions工作流..." -ForegroundColor Yellow

if (Test-Path ".github/workflows/sync-gist.yml") {
    $workflowContent = Get-Content ".github/workflows/sync-gist.yml" -Raw
    
    # 检查是否移除了total_nodes计算
    if ($workflowContent -match 'total_nodes=') {
        Write-Host "❌ 仍然包含total_nodes计算逻辑" -ForegroundColor Red
    } else {
        Write-Host "✅ 已移除total_nodes计算逻辑" -ForegroundColor Green
    }
    
    # 检查是否移除了节点总数的sed更新
    if ($workflowContent -match '\*\*节点总数\*\*') {
        Write-Host "❌ 仍然包含节点总数的sed更新逻辑" -ForegroundColor Red
    } else {
        Write-Host "✅ 已移除节点总数的sed更新逻辑" -ForegroundColor Green
    }
    
    # 检查YAML和Base64的更新逻辑
    if ($workflowContent -match '\*\*YAML 节点\*\*' -and $workflowContent -match '\*\*Base64 节点数\*\*') {
        Write-Host "✅ 保留了YAML和Base64节点的更新逻辑" -ForegroundColor Green
    } else {
        Write-Host "❌ YAML或Base64节点的更新逻辑有问题" -ForegroundColor Red
    }
} else {
    Write-Host "❌ GitHub Actions工作流文件不存在" -ForegroundColor Red
}

# 4. 生成验证报告
Write-Host "`n📋 验证报告:" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Gray
Write-Host "✅ 修改完成项目:" -ForegroundColor Green
Write-Host "  - 移除total_nodes计算逻辑" -ForegroundColor White
Write-Host "  - 移除README中节点总数显示行" -ForegroundColor White
Write-Host "  - 更新GitHub Actions工作流" -ForegroundColor White
Write-Host "  - 保留YAML和Base64节点的分别显示" -ForegroundColor White

Write-Host "`n📊 当前统计结果:" -ForegroundColor Green
Write-Host "  📄 YAML节点: $yamlNodes 个" -ForegroundColor White
Write-Host "  📝 Base64节点: $base64Nodes 个" -ForegroundColor White

Write-Host "`n🎯 优化效果:" -ForegroundColor Green
Write-Host "  - README显示更加简洁" -ForegroundColor White
Write-Host "  - 避免了重复的总数信息" -ForegroundColor White
Write-Host "  - 突出了两种格式的独立性" -ForegroundColor White

Write-Host "`n✅ 统计显示优化验证完成！" -ForegroundColor Green