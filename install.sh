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

# 4. 追加 CLAUDE.md（用标记包裹，支持干净卸载）
echo "--> 配置 CLAUDE.md..."
if [ ! -f "$CLAUDE_MD" ]; then
    # 全新安装
    {
        echo "$BEGIN_MARKER"
        cat "$SCRIPT_DIR/CLAUDE.md"
        echo ""
        echo "$END_MARKER"
    } > "$CLAUDE_MD"
    echo "    ✓ 已创建 $CLAUDE_MD"
elif grep -q "$BEGIN_MARKER" "$CLAUDE_MD" 2>/dev/null; then
    # 已有标记，替换为最新版
    # 删除旧标记段，追加新的（兼容 macOS/Linux）
    if sed --version >/dev/null 2>&1; then
        sed -i "/$BEGIN_MARKER/,/$END_MARKER/d" "$CLAUDE_MD"
    else
        sed -i '' "/$BEGIN_MARKER/,/$END_MARKER/d" "$CLAUDE_MD"
    fi
    {
        echo ""
        echo "$BEGIN_MARKER"
        cat "$SCRIPT_DIR/CLAUDE.md"
        echo ""
        echo "$END_MARKER"
    } >> "$CLAUDE_MD"
    echo "    ✓ 已更新工作流规则（替换旧版本）"
else
    # 首次追加
    {
        echo ""
        echo "$BEGIN_MARKER"
        cat "$SCRIPT_DIR/CLAUDE.md"
        echo ""
        echo "$END_MARKER"
    } >> "$CLAUDE_MD"
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
echo "    卸载: bash $(basename "$0" | sed 's/install/uninstall/')"
