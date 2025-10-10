# Safe test for changelog auto-add functionality
Write-Host "Testing changelog auto-add functionality (safe method)..." -ForegroundColor Cyan

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
$node_details = "📊 自动更新"
if ([int]$yaml_nodes -gt 0 -and [int]$base64_lines -gt 0) {
    $node_details = "📊 自动更新 - YAML:${yaml_nodes}个 Base64:${base64_lines}行"
} elseif ([int]$yaml_nodes -gt 0) {
    $node_details = "📊 自动更新 - YAML节点:${yaml_nodes}个"
} elseif ([int]$base64_lines -gt 0) {
    $node_details = "📊 自动更新 - Base64:${base64_lines}行"
}

Write-Host "Generated node details: $node_details" -ForegroundColor Cyan

try {
    # Read README content as array of lines
    $lines = Get-Content "README.md" -Encoding UTF8
    
    # Find the table header separator line
    $separatorIndex = -1
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match "^\\\|------|------|----------\\\|$") {
            $separatorIndex = $i
            break
        }
    }
    
    if ($separatorIndex -eq -1) {
        Write-Host "Table separator not found" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Found table separator at line $($separatorIndex + 1)" -ForegroundColor Green
    
    # Check if today's auto update record exists
    $todayRecordExists = $false
    $todayRecordIndex = -1
    for ($i = $separatorIndex + 1; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match "^\\\| $today_date.*自动更新") {
            $todayRecordExists = $true
            $todayRecordIndex = $i
            break
        }
    }
    
    # Create new record
    $newRecord = "| $current_date | ${total_nodes}个节点 | $node_details |"
    
    if (-not $todayRecordExists) {
        Write-Host "No auto update record for today, adding new record" -ForegroundColor Green
        
        # Insert new record after separator
        $newLines = @()
        $newLines += $lines[0..$separatorIndex]
        $newLines += $newRecord
        $newLines += $lines[($separatorIndex + 1)..($lines.Length - 1)]
        
        Write-Host "Added new changelog record: $current_date - $total_nodes 个节点" -ForegroundColor Green
    } else {
        Write-Host "Auto update record exists for today, updating existing record" -ForegroundColor Yellow
        
        # Update existing record
        $newLines = $lines.Clone()
        $newLines[$todayRecordIndex] = $newRecord
        
        Write-Host "Updated today's changelog record" -ForegroundColor Green
    }
    
    # Save updated content
    $newLines | Set-Content "README.md" -Encoding UTF8
    
    Write-Host "`nUpdated changelog table:" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    
    # Display first few lines of changelog
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
            if ($lineCount -gt 8) {
                break
            }
        }
    }
    
    Write-Host "`nTo restore original file, run: Move-Item README.md.backup README.md -Force" -ForegroundColor Yellow
    
} catch {
    Write-Host "Update failed: $($_.Exception.Message)" -ForegroundColor Red
}