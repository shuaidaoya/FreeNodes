# Test changelog auto-add functionality
Write-Host "Testing changelog auto-add functionality..." -ForegroundColor Cyan

# Simulate statistics data
$current_date = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$today_date = (Get-Date).ToString("yyyy-MM-dd")
$total_nodes = "150"
$yaml_nodes = "120"
$base64_lines = "30"

Write-Host "Simulated data:" -ForegroundColor Yellow
Write-Host "  - Current time: $current_date"
Write-Host "  - Today date: $today_date"
Write-Host "  - Total nodes: $total_nodes"
Write-Host "  - YAML nodes: $yaml_nodes"
Write-Host "  - Base64 lines: $base64_lines"

# Backup original README
if (Test-Path "README.md") {
    Copy-Item "README.md" "README.md.backup"
    Write-Host "Backed up original README.md" -ForegroundColor Green
} else {
    Write-Host "README.md file not found" -ForegroundColor Red
    exit 1
}

# Generate node details description
$node_details = "Auto update"
if ([int]$yaml_nodes -gt 0 -and [int]$base64_lines -gt 0) {
    $node_details = "Auto update - YAML:${yaml_nodes} Base64:${base64_lines}"
} elseif ([int]$yaml_nodes -gt 0) {
    $node_details = "Auto update - YAML:${yaml_nodes}"
} elseif ([int]$base64_lines -gt 0) {
    $node_details = "Auto update - Base64:${base64_lines}"
}

Write-Host "Generated node details: $node_details" -ForegroundColor Cyan

try {
    # Read README content
    $content = Get-Content "README.md" -Raw -Encoding UTF8
    
    # Check if today's auto update record exists
    $todayPattern = "\| $today_date.*Auto update"
    if ($content -notmatch $todayPattern) {
        Write-Host "No auto update record for today, adding new record" -ForegroundColor Green
        
        # Insert new record after table header
        $newRecord = "| $current_date | ${total_nodes} nodes | $node_details |"
        $content = $content -replace '(\|------|------|----------|)', "`$1`n$newRecord"
        
        Write-Host "Added new changelog record: $current_date - $total_nodes nodes" -ForegroundColor Green
    } else {
        Write-Host "Auto update record exists for today, updating existing record" -ForegroundColor Yellow
        
        # Update existing record
        $updatePattern = "\| $today_date.*\| [^|]* \| .*Auto update.* \|"
        $newRecord = "| $current_date | ${total_nodes} nodes | $node_details |"
        $content = $content -replace $updatePattern, $newRecord
        
        Write-Host "Updated today's changelog record" -ForegroundColor Green
    }
    
    # Save updated content
    $content | Set-Content "README.md" -Encoding UTF8
    
    Write-Host "`nUpdated changelog table:" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    
    # Display changelog table
    $lines = Get-Content "README.md" -Encoding UTF8
    $inChangelogSection = $false
    $lineCount = 0
    foreach ($line in $lines) {
        if ($line -match "## .* 更新日志") {
            $inChangelogSection = $true
        }
        if ($inChangelogSection) {
            Write-Host $line
            $lineCount++
            if ($lineCount -gt 10 -or ($line -match "^>" -and $lineCount -gt 5)) {
                break
            }
        }
    }
    
    Write-Host "`nTo restore original file, run: Move-Item README.md.backup README.md" -ForegroundColor Yellow
    
} catch {
    Write-Host "Update failed: $($_.Exception.Message)" -ForegroundColor Red
}