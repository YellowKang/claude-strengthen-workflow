# Claude Strengthen Workflow 安装脚本 (Windows PowerShell)
# 用法: .\install.ps1

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$ClaudeMD = Join-Path $ClaudeDir "CLAUDE.md"
$BeginMarker = "# >>> claude-strengthen-workflow >>>"
$EndMarker = "# <<< claude-strengthen-workflow <<<"

# 检查执行策略
$policy = Get-ExecutionPolicy
if ($policy -eq 'Restricted' -or $policy -eq 'AllSigned') {
    Write-Host "[警告] 当前执行策略为 $policy，若脚本被阻止请先运行：" -ForegroundColor Yellow
    Write-Host "    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "==> 安装 Claude Strengthen Workflow" -ForegroundColor Cyan
Write-Host ""

# 1. 创建目录
New-Item -ItemType Directory -Path "$ClaudeDir\agents" -Force | Out-Null
New-Item -ItemType Directory -Path "$ClaudeDir\skills" -Force | Out-Null

# 2. 安装 agents
Write-Host "--> 安装 agents..."
foreach ($f in Get-ChildItem "$ScriptDir\agents\*.md") {
    $dest = Join-Path "$ClaudeDir\agents" $f.Name
    if (Test-Path $dest) {
        $ans = Read-Host "    $($f.Name) 已存在，覆盖? [y/N]"
        if ($ans -notmatch "^[Yy]$") {
            Write-Host "    - 跳过 $($f.Name)"
            continue
        }
    }
    Copy-Item $f.FullName $dest -Force
    Write-Host "    ✓ agents/$($f.Name)" -ForegroundColor Green
}

# 3. 安装 skills
Write-Host "--> 安装 skills..."
$installed = 0
$skipped = 0
foreach ($dir in Get-ChildItem "$ScriptDir\skills" -Directory) {
    $dest = Join-Path "$ClaudeDir\skills" $dir.Name
    if (Test-Path $dest) {
        $diff = Compare-Object (Get-ChildItem $dir.FullName -Recurse -File | Where-Object { $_.Name -ne '.DS_Store' } | Get-FileHash) `
                               (Get-ChildItem $dest -Recurse -File | Where-Object { $_.Name -ne '.DS_Store' } | Get-FileHash) `
                               -Property Hash -ErrorAction SilentlyContinue
        if ($diff) {
            $ans = Read-Host "    skills/$($dir.Name)/ 已存在且内容不同，覆盖? [y/N]"
            if ($ans -notmatch "^[Yy]$") {
                $skipped++
                continue
            }
        }
    }
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Get-ChildItem -Path $dir.FullName -Recurse | Where-Object { $_.Name -notmatch '^\.DS_Store$' } | ForEach-Object {
        $target = $_.FullName.Replace($dir.FullName, $dest)
        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
        } else {
            Copy-Item $_.FullName $target -Force
        }
    }
    $installed++
}
Write-Host "    ✓ 安装 $installed 个 skill，跳过 $skipped 个" -ForegroundColor Green

# 4. 配置 CLAUDE.md
Write-Host "--> 配置 CLAUDE.md..."
$srcContent = Get-Content "$ScriptDir\CLAUDE.md" -Raw -Encoding UTF8

# 兼容 PS5/PS7 的无 BOM UTF-8 写入函数
function Write-UTF8NoBOM {
    param([string]$Path, [string]$Content)
    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

if (-not (Test-Path $ClaudeMD)) {
    # 全新安装
    Write-UTF8NoBOM $ClaudeMD ($BeginMarker + "`n" + $srcContent + "`n" + $EndMarker + "`n")
    Write-Host "    ✓ 已创建 CLAUDE.md" -ForegroundColor Green
}
elseif ((Get-Content $ClaudeMD -Raw -Encoding UTF8) -match [regex]::Escape($BeginMarker)) {
    # 已有标记，替换
    $content = Get-Content $ClaudeMD -Raw -Encoding UTF8
    $pattern = "(?s)" + [regex]::Escape($BeginMarker) + ".*?" + [regex]::Escape($EndMarker)
    $content = ($content -replace $pattern, "").TrimEnd() + "`n`n" + $BeginMarker + "`n" + $srcContent + "`n" + $EndMarker + "`n"
    Write-UTF8NoBOM $ClaudeMD $content
    Write-Host "    ✓ 已更新工作流规则（替换旧版本）" -ForegroundColor Green
}
else {
    # 首次追加
    $content = (Get-Content $ClaudeMD -Raw -Encoding UTF8).TrimEnd() + "`n`n" + $BeginMarker + "`n" + $srcContent + "`n" + $EndMarker + "`n"
    Write-UTF8NoBOM $ClaudeMD $content
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
Write-Host "    卸载: .\uninstall.ps1"
