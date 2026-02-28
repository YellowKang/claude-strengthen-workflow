#!/bin/bash
# Claude Strengthen Workflow 卸载脚本
# 用法: bash uninstall.sh

set -e

CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
BEGIN_MARKER="# >>> claude-strengthen-workflow >>>"
END_MARKER="# <<< claude-strengthen-workflow <<<"

AGENTS=(reviewer.md debugger.md designer.md)
SKILLS=(
    _common backend-conventions code-review db-api-design design-first
    docker-deploy env-strategy error-handling frontend-conventions
    go-conventions java-conventions mobile-cross-platform performance-checklist
    python-conventions react-conventions rust-conventions testing-strategy
    ui-ue-guidelines vue-conventions
)

echo "==> 卸载 Claude Strengthen Workflow"
echo ""

# 1. 删除 agents
echo "--> 删除 agents..."
for name in "${AGENTS[@]}"; do
    if [ -f "$CLAUDE_DIR/agents/$name" ]; then
        rm "$CLAUDE_DIR/agents/$name"
        echo "    ✓ 已删除 agents/$name"
    fi
done

# 2. 删除 skills
echo "--> 删除 skills..."
removed=0
for name in "${SKILLS[@]}"; do
    if [ -d "$CLAUDE_DIR/skills/$name" ]; then
        rm -rf "$CLAUDE_DIR/skills/$name"
        removed=$((removed+1))
    fi
done
echo "    ✓ 已删除 $removed 个 skill 目录"

# 3. 清理 CLAUDE.md 中的追加内容
echo "--> 清理 CLAUDE.md..."
if [ -f "$CLAUDE_MD" ] && grep -q "$BEGIN_MARKER" "$CLAUDE_MD" 2>/dev/null; then
    sed -i.bak "/$BEGIN_MARKER/,/$END_MARKER/d" "$CLAUDE_MD"
    rm -f "$CLAUDE_MD.bak"
    # 清理末尾空行
    sed -i.bak -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD"
    rm -f "$CLAUDE_MD.bak"
    echo "    ✓ 已清理 CLAUDE.md 中的工作流规则"
else
    echo "    - CLAUDE.md 中未找到工作流标记，跳过"
fi

echo ""
echo "==> 卸载完成！重新打开 Claude Code 即可生效。"
