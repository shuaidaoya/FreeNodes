# Simple test for changelog auto-add functionality
Write-Host "Testing changelog auto-add functionality (simple method)..." -ForegroundColor Cyan

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

# Backup original README
Copy-Item "README.md" "README.md.backup"
Write-Host "Backed up original README.md" -ForegroundColor Green

# Generate node details description
$node_details = "Auto update - YAML:${yaml_nodes} Base64:${base64_lines}"

Write-Host "Generated node details: $node_details" -ForegroundColor Cyan

try {
    # Read README content as array of lines
    $lines = Get-Content "README.md" -Encoding UTF8
    
    # Find the table header separator line (contains dashes)
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
    
    Write-Host "Found table separator at line $($separatorIndex + 1)" -ForegroundColor Green
    
    # Create new record
    $newRecord = "| $current_date | ${total_nodes} nodes | $node_details |"
    
    # Insert new record after separator
    $newLines = @()
    for ($i = 0; $i -le $separatorIndex; $i++) {
        $newLines += $lines[$i]
    }
    $newLines += $newRecord
    for ($i = $separatorIndex + 1; $i -lt $lines.Length; $i++) {
        $newLines += $lines[$i]
    }
    
    # Save updated content
    $newLines | Set-Content "README.md" -Encoding UTF8
    
    Write-Host "Added new changelog record: $current_date - $total_nodes nodes" -ForegroundColor Green
    
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