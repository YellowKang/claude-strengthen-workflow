## 编码规范自动加载
**仅在实际动手写/改代码前触发**（讨论、分析、看代码不触发），根据涉及文件类型用 Read 加载对应规范，只加载命中的，同一会话内同语言只加载一次：

**前端**（统一追加 `ui-ue-guidelines`）：
- 涉及 `.vue` → `~/.claude/skills/vue-conventions/SKILL.md` + `~/.claude/skills/frontend-conventions/SKILL.md` + `~/.claude/skills/ui-ue-guidelines/SKILL.md`
- 涉及 `.tsx/.jsx` → `~/.claude/skills/react-conventions/SKILL.md` + `~/.claude/skills/frontend-conventions/SKILL.md` + `~/.claude/skills/ui-ue-guidelines/SKILL.md`

**后端**：
- 涉及 `.go` → `~/.claude/skills/go-conventions/SKILL.md` + `~/.claude/skills/backend-conventions/SKILL.md`
- 涉及 `.java` → `~/.claude/skills/java-conventions/SKILL.md` + `~/.claude/skills/backend-conventions/SKILL.md`
- 涉及 `.py` → `~/.claude/skills/python-conventions/SKILL.md` + `~/.claude/skills/backend-conventions/SKILL.md`
- 涉及 `.rs` → `~/.claude/skills/rust-conventions/SKILL.md` + `~/.claude/skills/backend-conventions/SKILL.md`

**按需追加**：
- 涉及表设计/API → 额外加 `~/.claude/skills/db-api-design/SKILL.md`
- 涉及测试 → 额外加 `~/.claude/skills/testing-strategy/SKILL.md`
- 涉及部署/Docker → 额外加 `~/.claude/skills/docker-deploy/SKILL.md`

## 变更影响范围
每次改动前，主动评估跨端影响，不只改当前文件：
- 改后端接口（路径/参数/响应字段/状态码）→ 同步检查前端调用方是否需要联动
- 改前端 API 调用（字段/方法/参数）→ 确认后端接口是否匹配
- 改数据库字段/表结构 → 检查 ORM 映射、API 响应、前端绑定是否联动
- 改公共模块/工具函数 → grep 所有调用方，确认影响范围再动手
