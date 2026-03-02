#!/bin/bash
# Claude Strengthen Workflow 安装脚本
# 用法: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
BEGIN_MARKER="# >>> claude-strengthen-workflow >>>"
END_MARKER="# <<< claude-strengthen-workflow <<<"

echo "==> 安装 Claude Strengthen Workflow"
echo ""

# 0. 备份已有文件
BACKUP_DIR="$CLAUDE_DIR/.backup/$(date +%Y%m%d_%H%M%S)"
need_backup=false

[ -d "$CLAUDE_DIR/agents" ] && need_backup=true
[ -d "$CLAUDE_DIR/skills" ] && need_backup=true
[ -f "$CLAUDE_MD" ] && need_backup=true

if $need_backup; then
    echo "--> 备份已有文件到 $BACKUP_DIR ..."
    mkdir -p "$BACKUP_DIR"
    [ -d "$CLAUDE_DIR/agents" ] && cp -r "$CLAUDE_DIR/agents" "$BACKUP_DIR/agents" && echo "    ✓ agents/"
    [ -d "$CLAUDE_DIR/skills" ] && cp -r "$CLAUDE_DIR/skills" "$BACKUP_DIR/skills" && echo "    ✓ skills/"
    [ -f "$CLAUDE_MD" ] && cp "$CLAUDE_MD" "$BACKUP_DIR/CLAUDE.md" && echo "    ✓ CLAUDE.md"
    echo "    备份完成"
    echo ""
fi

# 1. 创建目录
mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills"

# 2. 安装 agents（已备份，直接覆盖）
echo "--> 安装 agents..."
for f in "$SCRIPT_DIR/agents/"*.md; do
    name=$(basename "$f")
    cp "$f" "$CLAUDE_DIR/agents/$name"
    echo "    ✓ agents/$name"
done

# 3. 安装 skills（已备份，直接覆盖）
echo "--> 安装 skills..."
installed=0
for dir in "$SCRIPT_DIR/skills/"*/; do
    name=$(basename "$dir")
    cp -r "$dir" "$CLAUDE_DIR/skills/$name"
    installed=$((installed+1))
done
echo "    ✓ 安装 $installed 个 skill"

# 4. 追加 CLAUDE.md 工作流规则
echo "--> 配置 CLAUDE.md..."
srcContent=$(cat "$SCRIPT_DIR/CLAUDE.md")

if [ ! -f "$CLAUDE_MD" ]; then
    printf '%s\n%s\n%s\n' "$BEGIN_MARKER" "$srcContent" "$END_MARKER" > "$CLAUDE_MD"
    echo "    ✓ 已创建 CLAUDE.md"
elif grep -qF "$BEGIN_MARKER" "$CLAUDE_MD"; then
    # 已有标记，替换旧版本
    # 用 awk 删除旧标记块
    awk -v bm="$BEGIN_MARKER" -v em="$END_MARKER" '
        $0 == bm { skip=1; next }
        $0 == em { skip=0; next }
        !skip { print }
    ' "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
    # 去除末尾空行后追加新内容
    sed -i'' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD.tmp" 2>/dev/null || true
    printf '\n\n%s\n%s\n%s\n' "$BEGIN_MARKER" "$srcContent" "$END_MARKER" >> "$CLAUDE_MD.tmp"
    mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
    echo "    ✓ 已更新工作流规则（替换旧版本）"
else
    # 首次追加
    printf '\n%s\n%s\n%s\n' "$BEGIN_MARKER" "$srcContent" "$END_MARKER" >> "$CLAUDE_MD"
    echo "    ✓ 工作流规则已追加到 CLAUDE.md"
fi

echo ""
echo "==> 安装完成！重新打开 Claude Code 即可生效。"
echo ""
echo "    已安装："
echo "    - 3 个 agents: reviewer / debugger / designer"
echo "    - $installed 个 skills"
echo "    - CLAUDE.md 工作规则"
echo ""
if $need_backup; then
    echo "    备份位置: $BACKUP_DIR"
fi
echo "    卸载: bash uninstall.sh"
