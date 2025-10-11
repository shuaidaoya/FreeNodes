# GitHub Actions File Change Detection Script
# Detects changes in specified files by comparing local and remote hashes

param(
    [string[]]$Files = @("all.yaml", "base64.txt", "history.yaml", "mihomo.yaml"),
    [string]$GistBaseUrl = "https://gist.githubusercontent.com/shuaidaoya/9e5cf2749c0ce79932dd9229d9b4162b/raw",
    [string]$LocalDir = "nodes"
)

# Initialize arrays
$changedFiles = @()
$unchangedFiles = @()
$failedFiles = @()

# Create temporary directory
$TempDir = Join-Path $env:TEMP "temp_download_$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# Logging functions
function Write-LogInfo($message) {
    Write-Host "ℹ️  [INFO] $message" -ForegroundColor Cyan
}

function Write-LogSuccess($message) {
    Write-Host "✅ [SUCCESS] $message" -ForegroundColor Green
}

function Write-LogError($message) {
    Write-Host "❌ [ERROR] $message" -ForegroundColor Red
}

function Write-LogWarning($message) {
    Write-Host "⚠️  [WARNING] $message" -ForegroundColor Yellow
}

Write-LogInfo "Starting file change detection..."
Write-LogInfo "Gist Base URL: $GistBaseUrl"
Write-LogInfo "Local Directory: $LocalDir"
Write-LogInfo "Files to check: $($Files -join ', ')"

foreach ($file in $Files) {
    Write-LogInfo "Checking file: $file"
    
    $localFile = Join-Path $LocalDir $file
    $remoteFile = Join-Path $TempDir $file
    $downloadUrl = "$GistBaseUrl/$file"
    
    # Download remote file
    $downloadSuccess = $false
    try {
        Write-LogInfo "Downloading remote file: $file"
        Invoke-WebRequest -Uri $downloadUrl -OutFile $remoteFile -UseBasicParsing
        $downloadSuccess = $true
        Write-LogSuccess "Download successful: $file"
    } catch {
        Write-LogError "Download failed: $file - $($_.Exception.Message)"
        $failedFiles += $file
        continue
    }
    
    if ($downloadSuccess) {
        # Calculate hashes
        $remoteHash = "FILE_NOT_EXISTS"
        $localHash = "FILE_NOT_EXISTS"
        
        if (Test-Path $remoteFile) {
            $remoteHashObj = Get-FileHash -Path $remoteFile -Algorithm SHA256
            $remoteHash = $remoteHashObj.Hash.ToLower()
        }
        
        if (Test-Path $localFile) {
            $localHashObj = Get-FileHash -Path $localFile -Algorithm SHA256
            $localHash = $localHashObj.Hash.ToLower()
        }
        
        # Output hashes for debugging
        $remoteHashShort = if ($remoteHash.Length -ge 16) { $remoteHash.Substring(0, 16) } else { $remoteHash }
        $localHashShort = if ($localHash.Length -ge 16) { $localHash.Substring(0, 16) } else { $localHash }
        Write-LogInfo "$file - Remote hash: $remoteHashShort..."
        Write-LogInfo "$file - Local hash: $localHashShort..."
        
        # Compare hashes
        if ($remoteHash -ne $localHash) {
            $changedFiles += $file
            Write-LogSuccess "✓ $file has changes"
        } else {
            $unchangedFiles += $file
            Write-LogInfo "○ $file no changes"
        }
    }
}

# Clean up temporary directory
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
    Write-LogInfo "Cleaned up temporary directory: $TempDir"
}

# Output detection results summary
Write-LogInfo "=== Detection Results Summary ==="
Write-LogInfo "Total files: $($Files.Count)"

if ($changedFiles.Count -gt 0) {
    Write-LogSuccess "Files with changes: $($changedFiles.Count)"
    Write-LogInfo "Changed files: $($changedFiles -join ', ')"
    
    # Output for GitHub Actions
    if ($env:GITHUB_OUTPUT) {
        Add-Content -Path $env:GITHUB_OUTPUT -Value "has_changes=true"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "changed_files=$($changedFiles -join ',')"
    }
    
    # Output changed files to stdout for script integration
    Write-Output ($changedFiles -join ',')
} else {
    Write-LogInfo "No changes detected"
    
    # Output for GitHub Actions
    if ($env:GITHUB_OUTPUT) {
        Add-Content -Path $env:GITHUB_OUTPUT -Value "has_changes=false"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "changed_files="
    }
    
    # Output empty string to stdout
    Write-Output ""
}

if ($unchangedFiles.Count -gt 0) {
    Write-LogInfo "Unchanged files: $($unchangedFiles -join ', ')"
}

if ($failedFiles.Count -gt 0) {
    Write-LogWarning "Failed files: $($failedFiles -join ', ')"
}

Write-LogInfo "Detection completed"