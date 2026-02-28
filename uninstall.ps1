# Claude Strengthen Workflow 卸载脚本 (Windows PowerShell)
# 用法: .\uninstall.ps1

$ErrorActionPreference = "Stop"

$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$ClaudeMD = Join-Path $ClaudeDir "CLAUDE.md"
$BeginMarker = "# >>> claude-strengthen-workflow >>>"
$EndMarker = "# <<< claude-strengthen-workflow <<<"

$Agents = @("reviewer.md", "debugger.md", "designer.md")
$Skills = @(
    "_common", "backend-conventions", "code-review", "db-api-design", "design-first",
    "docker-deploy", "env-strategy", "error-handling", "frontend-conventions",
    "go-conventions", "java-conventions", "mobile-cross-platform", "performance-checklist",
    "python-conventions", "react-conventions", "rust-conventions", "testing-strategy",
    "ui-ue-guidelines", "vue-conventions"
)

Write-Host "==> 卸载 Claude Strengthen Workflow" -ForegroundColor Cyan
Write-Host ""

# 1. 删除 agents
Write-Host "--> 删除 agents..."
foreach ($name in $Agents) {
    $path = Join-Path "$ClaudeDir\agents" $name
    if (Test-Path $path) {
        Remove-Item $path -Force
        Write-Host "    ✓ 已删除 agents/$name" -ForegroundColor Green
    }
}

# 2. 删除 skills
Write-Host "--> 删除 skills..."
$removed = 0
foreach ($name in $Skills) {
    $path = Join-Path "$ClaudeDir\skills" $name
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force
        $removed++
    }
}
Write-Host "    ✓ 已删除 $removed 个 skill 目录" -ForegroundColor Green

# 3. 清理 CLAUDE.md
Write-Host "--> 清理 CLAUDE.md..."
if ((Test-Path $ClaudeMD) -and ((Get-Content $ClaudeMD -Raw) -match [regex]::Escape($BeginMarker))) {
    $content = Get-Content $ClaudeMD -Raw
    $pattern = "(?s)" + [regex]::Escape($BeginMarker) + ".*?" + [regex]::Escape($EndMarker)
    $content = ($content -replace $pattern, "").TrimEnd() + "`n"
    $content | Set-Content $ClaudeMD -Encoding UTF8
    Write-Host "    ✓ 已清理 CLAUDE.md 中的工作流规则" -ForegroundColor Green
}
else {
    Write-Host "    - CLAUDE.md 中未找到工作流标记，跳过"
}

Write-Host ""
Write-Host "==> 卸载完成！重新打开 Claude Code 即可生效。" -ForegroundColor Cyan
