# Test updating existing changelog record with node details
Write-Host "Testing update of existing changelog record..." -ForegroundColor Cyan

# Simulate statistics data
$current_date = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$today_date = (Get-Date).ToString("yyyy-MM-dd")
$total_nodes = "125"
$yaml_nodes = "100"
$base64_lines = "25"

Write-Host "Simulated data:" -ForegroundColor Yellow
Write-Host "  - Current time: $current_date"
Write-Host "  - Today date: $today_date"
Write-Host "  - Total nodes: $total_nodes"
Write-Host "  - YAML nodes: $yaml_nodes"
Write-Host "  - Base64 lines: $base64_lines"

# Backup original README
Copy-Item "README.md" "README.md.backup"
Write-Host "Backed up original README.md" -ForegroundColor Green

try {
    # Read README content as array of lines
    $lines = Get-Content "README.md" -Encoding UTF8
    
    # First, add a test record for today to simulate existing record
    $separatorIndex = -1
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i].Contains("------|------|----------")) {
            $separatorIndex = $i
            break
        }
    }
    
    if ($separatorIndex -eq -1) {
        Write-Host "Table separator not found" -ForegroundColor Red
        exit 1
    }
    
    # Add a test record for today (simulating existing auto update record)
    $testRecord = "| $today_date 06:00:00 | 120个节点 | 📊 自动更新 |"
    $newLines = @()
    for ($i = 0; $i -le $separatorIndex; $i++) {
        $newLines += $lines[$i]
    }
    $newLines += $testRecord
    for ($i = $separatorIndex + 1; $i -lt $lines.Length; $i++) {
        $newLines += $lines[$i]
    }
    
    # Save with test record
    $newLines | Set-Content "README.md" -Encoding UTF8
    Write-Host "Added test record for today: $testRecord" -ForegroundColor Yellow
    
    # Now test the update logic
    # Generate node details description (same logic as in GitHub Actions)
    $node_details = "📊 自动更新"
    if ([int]$yaml_nodes -gt 0 -and [int]$base64_lines -gt 0) {
        $node_details = "📊 自动更新 - YAML:${yaml_nodes}个 Base64:${base64_lines}行"
    } elseif ([int]$yaml_nodes -gt 0) {
        $node_details = "📊 自动更新 - YAML节点:${yaml_nodes}个"
    } elseif ([int]$base64_lines -gt 0) {
        $node_details = "📊 自动更新 - Base64:${base64_lines}行"
    }
    
    Write-Host "Generated node details: $node_details" -ForegroundColor Cyan
    
    # Check if today's auto update record exists
    $content = Get-Content "README.md" -Raw -Encoding UTF8
    $autoUpdatePattern = "自动更新"
    
    if ($content -match "$today_date.*$autoUpdatePattern") {
        Write-Host "Found existing auto update record for today, updating..." -ForegroundColor Green
        
        # Find and replace the existing record
        $lines = Get-Content "README.md" -Encoding UTF8
        for ($i = 0; $i -lt $lines.Length; $i++) {
            if ($lines[$i] -match "$today_date.*$autoUpdatePattern") {
                $newRecord = "| $current_date | ${total_nodes}个节点 | $node_details |"
                $lines[$i] = $newRecord
                Write-Host "Updated existing record to: $newRecord" -ForegroundColor Green
                break
            }
        }
        
        # Save updated content
        $lines | Set-Content "README.md" -Encoding UTF8
    } else {
        Write-Host "No existing auto update record found for today" -ForegroundColor Red
    }
    
    Write-Host "`nUpdated changelog table:" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    
    # Display first few lines of changelog
    $updatedLines = Get-Content "README.md" -Encoding UTF8
    $inChangelogSection = $false
    $lineCount = 0
    foreach ($line in $updatedLines) {
        if ($line.Contains("更新日志")) {
            $inChangelogSection = $true
        }
        if ($inChangelogSection) {
            Write-Host $line
            $lineCount++
            if ($lineCount -gt 8) {
                break
            }
        }
    }
    
    Write-Host "`nTo restore original file, run: Move-Item README.md.backup README.md -Force" -ForegroundColor Yellow
    
} catch {
    Write-Host "Update failed: $($_.Exception.Message)" -ForegroundColor Red
}