param(
    [Parameter(Mandatory=$true)]
    [string]$ChangedFiles
)

# Configuration
$GistBaseUrl = "https://gist.githubusercontent.com/shuaidaoya/9e5cf2749c0ce79932dd9229d9b4162b/raw"
$ProjectRoot = "d:\Github\FreeNodes"

# Logging functions
function Write-LogInfo {
    param([string]$Message)
    Write-Host "[INFO] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" -ForegroundColor Cyan
}

function Write-LogSuccess {
    param([string]$Message)
    Write-Host "[SUCCESS] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" -ForegroundColor Green
}

function Write-LogError {
    param([string]$Message)
    Write-Host "[ERROR] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" -ForegroundColor Red
}

function Write-LogWarning {
    param([string]$Message)
    Write-Host "[WARNING] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" -ForegroundColor Yellow
}

# Create backup directory
function New-BackupDirectory {
    $backupDir = Join-Path $ProjectRoot "backup\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        Write-LogInfo "Created backup directory: $backupDir"
    }
    return $backupDir
}

# Backup existing files
function Backup-ExistingFiles {
    param(
        [array]$Files,
        [string]$BackupDir
    )
    
    Write-LogInfo "Backing up existing files..."
    foreach ($file in $Files) {
        $localFile = Join-Path $ProjectRoot "nodes\$file"
        if (Test-Path $localFile) {
            $backupFile = Join-Path $BackupDir $file
            $backupFileDir = Split-Path -Parent $backupFile
            if (-not (Test-Path $backupFileDir)) {
                New-Item -ItemType Directory -Path $backupFileDir -Force | Out-Null
            }
            Copy-Item -Path $localFile -Destination $backupFile -Force
            Write-LogInfo "Backed up file: $file"
        }
    }
}

# Update files
function Update-Files {
    param([array]$Files)
    
    Write-LogInfo "Starting file updates..."
    $updatedFiles = @()
    $failedFiles = @()
    
    # Create temporary directory
    $tempDir = Join-Path $ProjectRoot "temp_update_$(Get-Date -Format 'yyyyMMddHHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    try {
        foreach ($file in $Files) {
            Write-LogInfo "Updating file: $file"
            
            $url = "$GistBaseUrl/$file"
            $tempFile = Join-Path $tempDir $file
            $localFile = Join-Path $ProjectRoot "nodes\$file"
            
            try {
                # Download remote file
                Write-LogInfo "Downloading remote file: $file"
                Invoke-WebRequest -Uri $url -OutFile $tempFile -TimeoutSec 60 -UseBasicParsing -ErrorAction Stop
                
                # Ensure target directory exists
                $localFileDir = Split-Path -Parent $localFile
                if (-not (Test-Path $localFileDir)) {
                    New-Item -ItemType Directory -Path $localFileDir -Force | Out-Null
                }
                
                # Copy to target location
                Copy-Item -Path $tempFile -Destination $localFile -Force
                $updatedFiles += $file
                Write-LogSuccess "Update successful: $file"
                
            } catch {
                $failedFiles += $file
                Write-LogError "Update failed: $file - $($_.Exception.Message)"
            }
        }
    } finally {
        # Clean up temporary directory
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
            Write-LogInfo "Cleaned up temporary directory: $tempDir"
        }
    }
    
    return @{
        Updated = $updatedFiles
        Failed = $failedFiles
    }
}

# Verify update results
function Test-UpdateResult {
    param([array]$UpdatedFiles)
    
    Write-LogInfo "Verifying update results..."
    $verificationResults = @()
    
    foreach ($file in $UpdatedFiles) {
        $localFile = Join-Path $ProjectRoot "nodes\$file"
        if (Test-Path $localFile) {
            $fileSize = (Get-Item $localFile).Length
            $verificationResults += @{
                File = $file
                Exists = $true
                Size = $fileSize
            }
            Write-LogSuccess "Verification passed: $file (size: $fileSize bytes)"
        } else {
            $verificationResults += @{
                File = $file
                Exists = $false
                Size = 0
            }
            Write-LogError "Verification failed: $file does not exist"
        }
    }
    
    return $verificationResults
}

# Main execution logic
Write-LogInfo "Starting smart update process..."
Write-LogInfo "Changed files list: $ChangedFiles"

# Parse file list
$fileList = $ChangedFiles -split '[,\s]+' | Where-Object { $_.Trim() -ne "" }
Write-LogInfo "Parsed $($fileList.Count) files to update"

# Create backup
$backupDir = New-BackupDirectory
Backup-ExistingFiles -Files $fileList -BackupDir $backupDir

# Execute updates
$updateResult = Update-Files -Files $fileList

# Verify results
$verificationResult = Test-UpdateResult -UpdatedFiles $updateResult.Updated

# Output summary
Write-LogInfo "=== Update Results Summary ==="
Write-LogSuccess "Successfully updated: $($updateResult.Updated.Count) files"
if ($updateResult.Updated.Count -gt 0) {
    $updateResult.Updated | ForEach-Object { Write-LogSuccess "  - $_" }
}

if ($updateResult.Failed.Count -gt 0) {
    Write-LogError "Update failed: $($updateResult.Failed.Count) files"
    $updateResult.Failed | ForEach-Object { Write-LogError "  - $_" }
}

# Set GitHub Actions output
if ($env:GITHUB_OUTPUT) {
    $updatedFilesStr = $updateResult.Updated -join ','
    $failedFilesStr = $updateResult.Failed -join ','
    Add-Content -Path $env:GITHUB_OUTPUT -Value "updated_files=$updatedFilesStr"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "failed_files=$failedFilesStr"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "update_count=$($updateResult.Updated.Count)"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "backup_dir=$backupDir"
    Write-LogInfo "GitHub Actions output has been set"
}

Write-LogInfo "Smart update process completed"