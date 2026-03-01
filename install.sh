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

# 2. 安装 agents
echo "--> 安装 agents..."
for f in "$SCRIPT_DIR/agents/"*.md; do
    name=$(basename "$f")
    if [ -f "$CLAUDE_DIR/agents/$name" ]; then
        read -r -p "    agents/$name 已存在，覆盖? [y/N] " ans
        [[ "$ans" =~ ^[Yy]$ ]] || { echo "    - 跳过 agents/$name"; continue; }
    fi
    cp "$f" "$CLAUDE_DIR/agents/$name"
    echo "    ✓ agents/$name"
done

# 3. 安装 skills（同名提示，新增直接复制）
echo "--> 安装 skills..."
installed=0
skipped=0
for dir in "$SCRIPT_DIR/skills/"*/; do
    name=$(basename "$dir")
    if [ -d "$CLAUDE_DIR/skills/$name" ]; then
        # 已有同名 skill，比较内容
        if ! diff -rq "$dir" "$CLAUDE_DIR/skills/$name" >/dev/null 2>&1; then
            read -r -p "    skills/$name/ 已存在且内容不同，覆盖? [y/N] " ans
            [[ "$ans" =~ ^[Yy]$ ]] || { skipped=$((skipped+1)); continue; }
        fi
    fi
    cp -r "$dir" "$CLAUDE_DIR/skills/$name"
    installed=$((installed+1))
done
echo "    ✓ 安装 $installed 个 skill，跳过 $skipped 个"

# 4. 覆盖 CLAUDE.md（已在步骤 0 备份）
echo "--> 配置 CLAUDE.md..."
cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_MD"
echo "    ✓ 已覆盖 $CLAUDE_MD"

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
echo "    卸载: bash $(basename "$0" | sed 's/install/uninstall/')"
