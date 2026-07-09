---
name: commit-message-convention
description: Draft and review commit messages for this repository using the required Conventional Commits-style type list. Use when Codex creates a commit, suggests a commit message, reviews commit text, writes changelog-ready summaries, or checks whether a proposed commit message is acceptable.
---

# Commit Message Convention

## Overview

Use this skill whenever preparing or validating a commit message for this repository. A valid commit message must use one of the approved types and the format `type(scope): subject`.

## Required Format

Use this header format:

```text
type(scope): subject
```

Requirements:

- Use exactly one approved type from the list below.
- Include a non-empty scope in parentheses. Choose the smallest meaningful subsystem, package, module, generator, test area, or documentation area, such as `boom`, `rocket`, `chipyard`, `docs`, `ci`, or `build`.
- Add a colon and one space after the scope.
- Write a concise subject that states the change in imperative or descriptive style.
- Do not end the subject with a period.
- Use a body when the change needs rationale, risk notes, verification details, or context that does not fit in the subject.

## Approved Types

- `fix`: 修复代码库中的 bug。
- `feat`: 在代码库中新增功能。
- `build`: 修改项目构建系统，例如依赖库、外部接口、Node 版本或类似构建输入。
- `chore`: 修改非业务性代码，例如构建流程、工具配置、维护脚本或仓库管理内容。
- `ci`: 修改持续集成流程，例如 Travis、Jenkins、GitHub Actions 或其他工作流配置。
- `docs`: 修改文档，例如 README、API 文档、设计说明或注释性文档。
- `style`: 修改代码样式，例如缩进、空格、空行、格式化，不改变逻辑。
- `refactor`: 重构代码，例如修改结构、变量名、函数名或拆分代码，不改变功能逻辑。
- `perf`: 优化性能，例如提升运行速度、吞吐、仿真效率或减少内存占用。
- `test`: 修改测试用例，例如添加、删除、修正或重构测试。
- `power`: 功耗优化。
- `area`: 面积优化。
- `timing`: 时序优化。

## Workflow

When drafting a commit message:

1. Inspect the actual diff or user-described change before choosing a type.
2. Select the most specific approved type. Prefer `power`, `area`, or `timing` over generic `perf` when the change is specifically about those hardware quality targets.
3. Choose a narrow scope from the touched component, not a broad repository label unless the change is truly cross-cutting.
4. Draft the header in the required format.
5. Add a body only when it helps future readers understand why the change was made or how it was verified.

When reviewing a proposed commit message:

- Reject messages whose type is not in the approved list.
- Reject messages missing the `scope`.
- Reject messages missing the `: ` separator.
- Reject messages with an empty or vague subject.
- Suggest a corrected message instead of only pointing out the violation.

## Examples

```text
fix(boom): handle branch recovery after exception redirect

feat(chipyard): add configurable harness clock divider

build(deps): update verilator integration flags

docs(readme): clarify FireSim setup requirements

power(rocket): gate multiplier clock when idle

area(cache): reduce metadata array width

timing(tilelink): pipeline manager response path
```

## Body Guidance

Use a blank line between the header and body:

```text
fix(boom): preserve redirect priority on flush

The old priority order allowed a later flush to hide an exception redirect.
Keep the exception redirect visible until recovery state has been recorded.

Verification: ran boom unit tests.
```
