@echo off
echo Testing README stats update...

powershell -Command "& {
    $current_utc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss UTC')
    $total_nodes = '150'
    $yaml_nodes = '120'
    $base64_lines = '30'
    
    Write-Host 'Testing with data:'
    Write-Host '  Time: ' $current_utc
    Write-Host '  Total nodes: ' $total_nodes
    Write-Host '  YAML nodes: ' $yaml_nodes
    Write-Host '  Base64 lines: ' $base64_lines
    
    Copy-Item 'README.md' 'README.md.backup'
    Write-Host 'Backup created'
    
    $content = Get-Content 'README.md' -Raw -Encoding UTF8
    $content = $content -replace '\| 🕐 \*\*最后更新时间\*\* \| .* \|', ('| 🕐 **最后更新时间** | ' + $current_utc + ' |')
    $content = $content -replace '\| 🌐 \*\*节点总数\*\* \| .* \|', ('| 🌐 **节点总数** | ' + $total_nodes + ' 个 |')
    $content = $content -replace '\| 📄 \*\*YAML 节点\*\* \| .* \|', ('| 📄 **YAML 节点** | ' + $yaml_nodes + ' 个 |')
    $content = $content -replace '\| 📝 \*\*Base64 行数\*\* \| .* \|', ('| 📝 **Base64 行数** | ' + $base64_lines + ' 行 |')
    $content = $content -replace '\| 🔄 \*\*同步状态\*\* \| .* \|', '| 🔄 **同步状态** | 🟢 已同步 |'
    
    $content | Set-Content 'README.md' -Encoding UTF8
    Write-Host 'README.md updated successfully!'
    Write-Host 'To restore: move README.md.backup README.md'
}"

pause