param(
  [int]$YamlNodes = 0,
  [int]$Base64Lines = 0,
  [string]$Label = '主同步',
  [string]$ReadmePath = 'README.md',
  [int]$MaxLogRows = 10,
  [string]$GistUpdatedAt = ''
)

$ErrorActionPreference = 'Stop'
$now = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss 北京时间')
if (Test-Path $ReadmePath) {
  $readme = Get-Content $ReadmePath -Raw
} else {
  $readme = ""
}
$start = '<!-- AUTO_STATS_START -->'
$end = '<!-- AUTO_STATS_END -->'

# 构建与当前 README 模板一致的二列表格（项目 | 状态）
$statsBlock = @"
## 📊 实时统计
节点速度最低1m/s,以GitHub为测试地址,建议先测一遍速，剔除不可用节点，再进行使用
| 项目 | 状态 |
|------|------|
| 🕐 **最后更新时间** | $now |
| 📄 **YAML 节点** | $YamlNodes 个 |
| 📝 **Base64 节点数** | $Base64Lines 个 |
| 🔄 **同步状态** | $Label |
"@

if ($readme.Contains($start) -and $readme.Contains($end)) {
  $pre = $readme.Substring(0, $readme.IndexOf($start))
  $post = $readme.Substring($readme.IndexOf($end) + $end.Length)
  $new = $pre + $start + "`n" + $statsBlock + $end + $post
  Set-Content -Path $ReadmePath -Value $new -NoNewline
} else {
  $new = $readme + "`n" + $start + "`n" + $statsBlock + $end + "`n"
  Set-Content -Path $ReadmePath -Value $new -NoNewline
}

$content = Get-Content $ReadmePath -Raw
if (![string]::IsNullOrWhiteSpace($GistUpdatedAt)) {
  $markerPattern = '<!--\s*GIST_UPDATED_AT:\s*.*?-->'
  $marker = "<!-- GIST_UPDATED_AT: $GistUpdatedAt -->"
  if ([System.Text.RegularExpressions.Regex]::IsMatch($content, $markerPattern)) {
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, $markerPattern, $marker, 1)
  } elseif ($content.Contains($end)) {
    $content = $content.Replace($end, $end + "`n" + $marker)
  } else {
    $content = $content + "`n" + $marker + "`n"
  }
  Set-Content -Path $ReadmePath -Value $content -NoNewline
  $content = Get-Content $ReadmePath -Raw
}

$date = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
$summary = "YAML:$YamlNodes 个, Base64:$Base64Lines 个"
$headerPattern = '\|------\|------\|----------\|'
$linesCurrent = $content -split "`r?`n"
$headerIndexCurrent = -1
for ($i = 0; $i -lt $linesCurrent.Length; $i++) { if ($linesCurrent[$i] -eq "|------|------|----------|") { $headerIndexCurrent = $i; break } }
$existingYaml = -1
$existingBase64 = -1
if ($headerIndexCurrent -ge 0 -and ($headerIndexCurrent + 1) -lt $linesCurrent.Length) {
  $firstRow = $linesCurrent[$headerIndexCurrent + 1]
  if ($firstRow -match 'YAML:(\d+)\s*个') { $existingYaml = [int]$Matches[1] }
  if ($firstRow -match 'Base64:(\d+)\s*个') { $existingBase64 = [int]$Matches[1] }
}
$shouldInsert = $true
if ($headerIndexCurrent -ge 0 -and $existingYaml -ge 0 -and $existingBase64 -ge 0) {
  if ($existingYaml -eq $YamlNodes -and $existingBase64 -eq $Base64Lines) { $shouldInsert = $false }
}
if ([System.Text.RegularExpressions.Regex]::IsMatch($content, $headerPattern)) {
  if ($shouldInsert) {
    $newContent = [System.Text.RegularExpressions.Regex]::Replace(
      $content,
      $headerPattern,
      "|------|------|----------|`n| $date | $summary | 📊 自动更新 |",
      1
    )
  } else {
    $newContent = $content
  }
} else {
  $newContent = $readme + "`n## 📋 更新日志`n| 时间 -仅保留最新10条 | 节点数量 | 更新方式 |`n|------|------|----------|`n| $date | $summary | 📊 自动更新 |"
}

$lines = $newContent -split "`r?`n"
$headerIndex = -1
for ($i = 0; $i -lt $lines.Length; $i++) { if ($lines[$i] -eq "|------|------|----------|") { $headerIndex = $i; break } }
if ($headerIndex -ge 0) {
  $rows = @()
  for ($j = $headerIndex + 1; $j -lt $lines.Length; $j++) {
    $line = $lines[$j]
    if ($line -match '^\|') { $rows += $line } else { break }
  }
  $keep = [Math]::Min($rows.Count, $MaxLogRows)
  $rowsToKeep = @()
  if ($keep -gt 0) { $rowsToKeep = $rows[0..($keep-1)] }
  $before = @()
  if ($headerIndex -ge 0) { $before = $lines[0..$headerIndex] }
  $afterStart = $headerIndex + 1 + $rows.Count
  $after = @()
  if ($afterStart -lt $lines.Length) { $after = $lines[$afterStart..($lines.Length-1)] }
  $final = ($before + $rowsToKeep + $after) -join "`n"
  Set-Content -Path $ReadmePath -Value $final -NoNewline
} else {
  Set-Content -Path $ReadmePath -Value $newContent -NoNewline
}
