# Claude Strengthen Workflow

> Language / 语言：[中文](./README.md)｜**English**

A Claude Code workflow enhancement for full-stack development, covering the complete lifecycle from design → coding → review → debugging.

## What's Included

### 3 Subagents

| Agent | Role | Trigger |
|-------|------|---------|
| `designer` | Generate design docs (tech spec + UI/UX) | New feature / large change involving 3+ files |
| `reviewer` | Review code and fix issues directly | After code is written, or on explicit request |
| `debugger` | Locate root cause and apply minimal fix | Build failure, test error, unexpected behavior |

### 20 Skills (grouped by tech stack)

- **Frontend**: vue-conventions, react-conventions, frontend-conventions, ui-ue-guidelines, mobile-cross-platform
- **Backend**: go-conventions, java-conventions, python-conventions, rust-conventions, backend-conventions
- **General**: code-review, testing-strategy, performance-checklist, db-api-design, error-handling, design-first, docker-deploy, env-strategy

### CLAUDE.md Rules

- **Auto-load coding conventions**: Reads the matching skill before writing code, based on file type. No duplicate loads within the same session.
- **Change impact scope**: Automatically evaluates cross-layer (frontend ↔ backend) impact before making changes.

## Installation

```bash
git clone git@github.com:YellowKang/claude-strengthen-workflow.git
cd claude-strengthen-workflow
bash install.sh
```

Restart Claude Code to take effect.

> `install.sh` appends to your existing `~/.claude/CLAUDE.md` rather than overwriting it. For agents with the same filename, it will prompt before overwriting.

## Workflow Overview

```
Describe a feature (3+ files involved)
  → designer agent writes design doc first (tech spec + UI/UX four-state coverage)

Start coding
  → Auto-load language conventions (Go / Vue / React / Java / Python / Rust)
  → Auto-check cross-layer impact scope

Build failure / test error
  → debugger agent locates root cause + applies minimal fix

After coding
  → reviewer agent checks quality / security / performance, fixes issues directly
```

## Uninstall

```bash
rm ~/.claude/agents/{reviewer,debugger,designer}.md
# Remove skill directories as needed
```
