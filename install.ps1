# Claude Strengthen Workflow 安装脚本 (Windows PowerShell)
# 用法: .\install.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$ClaudeMD = Join-Path $ClaudeDir "CLAUDE.md"
$BeginMarker = '# >>> claude-strengthen-workflow >>>'
$EndMarker = '# <<< claude-strengthen-workflow <<<'

Write-Host "==> 安装 Claude Strengthen Workflow" -ForegroundColor Cyan
Write-Host ""

# 0. 备份已有文件
$needBackup = (Test-Path "$ClaudeDir\agents") -or (Test-Path "$ClaudeDir\skills") -or (Test-Path $ClaudeMD)
$BackupDir = ""

if ($needBackup) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $BackupDir = Join-Path $ClaudeDir ".backup\$timestamp"
    Write-Host "--> 备份已有文件到 $BackupDir ..."
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

    if (Test-Path "$ClaudeDir\agents") {
        Copy-Item "$ClaudeDir\agents" "$BackupDir\agents" -Recurse -Force
        Write-Host "    ✓ agents/" -ForegroundColor Green
    }
    if (Test-Path "$ClaudeDir\skills") {
        Copy-Item "$ClaudeDir\skills" "$BackupDir\skills" -Recurse -Force
        Write-Host "    ✓ skills/" -ForegroundColor Green
    }
    if (Test-Path $ClaudeMD) {
        Copy-Item $ClaudeMD "$BackupDir\CLAUDE.md" -Force
        Write-Host "    ✓ CLAUDE.md" -ForegroundColor Green
    }
    Write-Host "    备份完成"
    Write-Host ""
}

# 1. 创建目录
New-Item -ItemType Directory -Path "$ClaudeDir\agents" -Force | Out-Null
New-Item -ItemType Directory -Path "$ClaudeDir\skills" -Force | Out-Null

# 2. 安装 agents（已备份，直接覆盖）
Write-Host "--> 安装 agents..."
foreach ($f in Get-ChildItem "$ScriptDir\agents\*.md") {
    $dest = Join-Path "$ClaudeDir\agents" $f.Name
    Copy-Item $f.FullName $dest -Force
    Write-Host "    ✓ agents/$($f.Name)" -ForegroundColor Green
}

# 3. 安装 skills（已备份，直接覆盖）
Write-Host "--> 安装 skills..."
$installed = 0
foreach ($dir in Get-ChildItem "$ScriptDir\skills" -Directory) {
    $dest = Join-Path "$ClaudeDir\skills" $dir.Name
    Copy-Item $dir.FullName $dest -Recurse -Force
    $installed++
}
Write-Host "    ✓ 安装 $installed 个 skill" -ForegroundColor Green

# 4. 追加 CLAUDE.md 工作流规则
Write-Host "--> 配置 CLAUDE.md..."
$srcContent = Get-Content "$ScriptDir\CLAUDE.md" -Raw

if (-not (Test-Path $ClaudeMD)) {
    "$BeginMarker`n$srcContent`n$EndMarker" | Set-Content $ClaudeMD -Encoding UTF8
    Write-Host "    ✓ 已创建 CLAUDE.md" -ForegroundColor Green
}
elseif ((Get-Content $ClaudeMD -Raw) -match [regex]::Escape($BeginMarker)) {
    $content = Get-Content $ClaudeMD -Raw
    $pattern = '(?s)' + [regex]::Escape($BeginMarker) + '.*?' + [regex]::Escape($EndMarker)
    $content = $content -replace $pattern, ""
    $content = $content.TrimEnd() + "`n`n$BeginMarker`n$srcContent`n$EndMarker`n"
    $content | Set-Content $ClaudeMD -Encoding UTF8
    Write-Host "    ✓ 已更新工作流规则（替换旧版本）" -ForegroundColor Green
}
else {
    Add-Content $ClaudeMD "`n$BeginMarker`n$srcContent`n$EndMarker" -Encoding UTF8
    Write-Host "    ✓ 工作流规则已追加到 CLAUDE.md" -ForegroundColor Green
}

Write-Host ""
Write-Host "==> 安装完成！重新打开 Claude Code 即可生效。" -ForegroundColor Cyan
Write-Host ""
Write-Host "    已安装："
Write-Host "    - 3 个 agents: reviewer / debugger / designer"
Write-Host "    - $installed 个 skills"
Write-Host "    - CLAUDE.md 工作规则"
Write-Host ""
if ($BackupDir) {
    Write-Host "    备份位置: $BackupDir"
}
Write-Host '    卸载: .\uninstall.ps1'
