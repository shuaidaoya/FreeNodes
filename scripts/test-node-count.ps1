# Test node count statistics
Write-Host "Testing node count statistics..." -ForegroundColor Cyan

# Check if files exist
$yamlFile = "nodes/all.yaml"
$base64File = "nodes/base64.txt"

Write-Host "`nChecking files:" -ForegroundColor Yellow
Write-Host "  - YAML file: $yamlFile - $(if (Test-Path $yamlFile) { 'EXISTS' } else { 'NOT FOUND' })"
Write-Host "  - Base64 file: $base64File - $(if (Test-Path $base64File) { 'EXISTS' } else { 'NOT FOUND' })"

# Initialize counters
$total_nodes = 0
$yaml_nodes = 0
$base64_lines = 0

# Count YAML nodes
if (Test-Path $yamlFile) {
    try {
        $yamlContent = Get-Content $yamlFile -ErrorAction Stop
        $yaml_nodes = ($yamlContent | Select-String "server:" | Measure-Object).Count
        $total_nodes += $yaml_nodes
        Write-Host "  - YAML nodes found: $yaml_nodes" -ForegroundColor Green
    } catch {
        Write-Host "  - Error reading YAML file: $($_.Exception.Message)" -ForegroundColor Red
        $yaml_nodes = 0
    }
} else {
    Write-Host "  - YAML file not found, using 0" -ForegroundColor Yellow
}

# Count Base64 lines
if (Test-Path $base64File) {
    try {
        $base64Content = Get-Content $base64File -ErrorAction Stop
        $base64_lines = $base64Content.Count
        $total_nodes += $base64_lines
        Write-Host "  - Base64 lines found: $base64_lines" -ForegroundColor Green
    } catch {
        Write-Host "  - Error reading Base64 file: $($_.Exception.Message)" -ForegroundColor Red
        $base64_lines = 0
    }
} else {
    Write-Host "  - Base64 file not found, using 0" -ForegroundColor Yellow
}

Write-Host "`nStatistics Summary:" -ForegroundColor Cyan
Write-Host "  - YAML nodes: $yaml_nodes"
Write-Host "  - Base64 lines: $base64_lines"
Write-Host "  - Total nodes: $total_nodes" -ForegroundColor Green

# Simulate the GitHub Actions logic
Write-Host "`nSimulating GitHub Actions output:" -ForegroundColor Cyan
Write-Host "yaml_nodes=$yaml_nodes"
Write-Host "base64_lines=$base64_lines"
Write-Host "total_nodes=$total_nodes"
Write-Host "📊 统计到 $total_nodes 个节点 (YAML: $yaml_nodes, Base64: $base64_lines)"

# Show what the changelog entry would look like
$current_date = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$node_details = "📊 自动更新"
if ($yaml_nodes -gt 0 -and $base64_lines -gt 0) {
    $node_details = "📊 自动更新 - YAML:${yaml_nodes}个 Base64:${base64_lines}行"
} elseif ($yaml_nodes -gt 0) {
    $node_details = "📊 自动更新 - YAML节点:${yaml_nodes}个"
} elseif ($base64_lines -gt 0) {
    $node_details = "📊 自动更新 - Base64:${base64_lines}行"
}

Write-Host "`nChangelog entry would be:" -ForegroundColor Cyan
Write-Host "| $current_date | ${total_nodes}个节点 | $node_details |" -ForegroundColor Green