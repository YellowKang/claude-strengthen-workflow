#!/bin/bash
# Claude Strengthen Workflow 安装脚本
# 用法: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "==> 安装 Claude Strengthen Workflow"

# 1. 创建目录
mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills"

# 2. 复制 agents（已有同名文件则提示覆盖）
echo "--> 安装 agents..."
for f in "$SCRIPT_DIR/agents/"*.md; do
    name=$(basename "$f")
    if [ -f "$CLAUDE_DIR/agents/$name" ]; then
        read -r -p "    agents/$name 已存在，覆盖? [y/N] " ans
        [[ "$ans" =~ ^[Yy]$ ]] || continue
    fi
    cp "$f" "$CLAUDE_DIR/agents/$name"
    echo "    ✓ agents/$name"
done

# 3. 复制 skills（整体覆盖，不影响用户自定义 skill）
echo "--> 安装 skills..."
cp -r "$SCRIPT_DIR/skills/." "$CLAUDE_DIR/skills/"
echo "    ✓ skills/ 全部安装完成"

# 4. 追加 CLAUDE.md 章节（不覆盖，追加到末尾）
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
MARKER="## 编码规范自动加载"

if grep -q "$MARKER" "$CLAUDE_MD" 2>/dev/null; then
    echo "--> CLAUDE.md 中已有工作流规则，跳过（如需更新请手动替换）"
else
    echo "" >> "$CLAUDE_MD"
    cat "$SCRIPT_DIR/CLAUDE.md" >> "$CLAUDE_MD"
    echo "--> ✓ 工作流规则已追加到 $CLAUDE_MD"
fi

echo ""
echo "==> 安装完成！重新打开 Claude Code 即可生效。"
echo ""
echo "    已安装内容："
echo "    - agents: reviewer / debugger / designer"
echo "    - skills: $(ls "$SCRIPT_DIR/skills/" | grep -v '^_' | wc -l | tr -d ' ') 个技术规范"
echo "    - CLAUDE.md: 编码规范自动加载 + 变更影响范围"
