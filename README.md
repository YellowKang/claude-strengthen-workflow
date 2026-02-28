# Claude Strengthen Workflow

> 语言 / Language：**中文**｜[English](./README_EN.md)

面向全栈开发的 Claude Code 增强工作流，覆盖从设计 → 编码 → 审查 → 调试的完整开发生命周期。

## 包含内容

### 3 个 Subagents

| Agent | 职责 | 触发时机 |
|-------|------|---------|
| `designer` | 生成设计文档（技术方案 + UI/UX） | 新功能/大改动，涉及 3+ 文件 |
| `reviewer` | 代码审查并直接修复问题 | 代码写完后，或主动请求检查 |
| `debugger` | 定位根因并最小化修复 | 构建失败、测试报错、异常行为 |

### 20 个 Skills（按技术栈分组）

- **前端**：vue-conventions、react-conventions、frontend-conventions、ui-ue-guidelines、mobile-cross-platform
- **后端**：go-conventions、java-conventions、python-conventions、rust-conventions、backend-conventions
- **通用**：code-review、testing-strategy、performance-checklist、db-api-design、error-handling、design-first、docker-deploy、env-strategy

### CLAUDE.md 规则

- **编码规范自动加载**：写代码前按文件类型自动读取对应规范，同会话不重复加载
- **变更影响范围**：改动时自动评估前后端联动影响

## 安装

```bash
git clone git@github.com:YellowKang/claude-strengthen-workflow.git
cd claude-strengthen-workflow
bash install.sh
```

重新打开 Claude Code 即可生效。

> `install.sh` 会追加而不是覆盖你已有的 `~/.claude/CLAUDE.md`，agents 同名文件会提示确认。

## 工作流示意

```
说需求（涉及 3+ 文件）
  → designer agent 先出设计文档（技术方案 + UI/UX 四态）

动手写代码
  → 自动加载对应语言规范（Go/Vue/React/Java/Python/Rust）
  → 自动检查跨端影响范围

出错/构建失败
  → debugger agent 定位根因 + 最小化修复

写完后
  → reviewer agent 审查质量/安全/性能，发现问题直接修复
```

## 卸载

```bash
rm ~/.claude/agents/{reviewer,debugger,designer}.md
# skills 按需删除对应目录
```
