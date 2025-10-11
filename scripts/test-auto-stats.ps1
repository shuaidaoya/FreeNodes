# Test Auto Stats Function
Write-Host "Testing Auto Stats Function..." -ForegroundColor Yellow

# Mock statistics data
$current_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss UTC")
$yaml_nodes = 121
$base64_lines = 1
$total_nodes = $yaml_nodes + $base64_lines

Write-Host "Mock Statistics Data:" -ForegroundColor Cyan
Write-Host "  - Update Time: $current_utc"
Write-Host "  - YAML Nodes: $yaml_nodes"
Write-Host "  - Base64 Lines: $base64_lines"
Write-Host "  - Total Nodes: $total_nodes"

try {
    # Create backup
    Copy-Item "README.md" "README.md.backup" -Force
    Write-Host "Backup created: README.md.backup" -ForegroundColor Green
    
    # Read file content
    $content = Get-Content "README.md" -Raw -Encoding UTF8
    
    # Check if AUTO_STATS area exists
    if ($content -match '(?s)<!-- AUTO_STATS_START -->.*?<!-- AUTO_STATS_END -->') {
        Write-Host "Found AUTO_STATS area" -ForegroundColor Green
        
        # Simple replacements
        $content = $content -replace '等待首次同步\.\.\.', $current_utc
        $content = $content -replace '统计中\.\.\.', "$total_nodes 个"
        
        # Write updated content
        Set-Content "README.md" -Value $content -Encoding UTF8 -NoNewline
        Write-Host "README.md real-time statistics updated successfully" -ForegroundColor Green
        
        # Show updated area
        Write-Host "`nUpdated Statistics Area:" -ForegroundColor Cyan
        $updatedContent = Get-Content "README.md" -Raw -Encoding UTF8
        if ($updatedContent -match '(?s)(<!-- AUTO_STATS_START -->.*?<!-- AUTO_STATS_END -->)') {
            Write-Host $matches[1]
        }
    } else {
        Write-Host "ERROR: AUTO_STATS area not found" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTo restore original file, run: Move-Item README.md.backup README.md -Force" -ForegroundColor Yellow