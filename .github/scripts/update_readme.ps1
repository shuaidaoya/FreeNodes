param(
  [int]$YamlNodes = 0,
  [int]$Base64Lines = 0,
  [string]$Label = '主同步',
  [string]$ReadmePath = 'README.md'
)

$ErrorActionPreference = 'Stop'
if (!(Test-Path $ReadmePath)) { Write-Host "README 不存在，跳过"; exit 0 }
$now = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss 北京时间')
$readme = Get-Content $ReadmePath -Raw
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

# 在更新日志表格中插入记录（若存在表头）
$date = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
$summary = "YAML:$YamlNodes 个, Base64:$Base64Lines 个"
$content = Get-Content $ReadmePath -Raw
$headerPattern = '\|------\|------\|----------\|'
if ([System.Text.RegularExpressions.Regex]::IsMatch($content, $headerPattern)) {
  $newContent = [System.Text.RegularExpressions.Regex]::Replace(
    $content,
    $headerPattern,
    "|------|------|----------|`n| $date | $summary | 📊 自动更新 |",
    1
  )
  Set-Content -Path $ReadmePath -Value $newContent -NoNewline
}
