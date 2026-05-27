# User Memory

## Edit Discipline

Before editing any file, read it first. Before modifying a function, grep for all callers. Research before you edit.

## File Management Policy

**NEVER create new files unless absolutely necessary.** ALWAYS prioritize editing existing files over creating new ones. This includes:
- Documentation files (README.md, docs, etc.)
- Configuration files
- Code files
- Any other project files

Only create a new file when explicitly requested or when the file genuinely does not exist and is essential for the task.

## Analyzing Remote Codebases

For remote GitHub repositories, use gitingest + Gemini CLI to save tokens:

```bash
# Create digest
gitingest https://github.com/user/repo -o /tmp/repo_digest.txt

# Analyze with Gemini
gemini /tmp/repo_digest.txt "find X pattern or explain Y"

# Cleanup
rm /tmp/repo_digest.txt
```

For private repos, add `-t $GITHUB_TOKEN`

## Context7 MCP for Documentation Validation

When making changes to code that involves libraries, frameworks, or APIs, ALWAYS use Context7 MCP to validate against up-to-date documentation before implementing:

### When to Use Context7

- Before implementing new features with external libraries
- When updating existing code that uses third-party dependencies
- Before suggesting API usage patterns or method calls
- When troubleshooting library-specific issues
- When the user asks about best practices for specific frameworks

### Usage Pattern

**IMPORTANT**: Always use context7 via an Explore subagent, not directly. This ensures efficient token usage and proper context management.

1. **Spawn Explore Agent**: Use the Task tool with `subagent_type=Explore` to research documentation
2. **Provide Clear Task**: Give the Explore agent a specific prompt about what documentation to validate
3. **Validation**: The agent will use context7 tools to check current API patterns
4. **Implementation**: Proceed with confidence using the validated, up-to-date examples

### Example Usage

```
# Correct approach - use Explore subagent
Task tool with subagent_type=Explore: "Use context7 to research NextAuth.js authentication patterns and validate the current API for implementing user login"

# Incorrect - don't call context7 MCP tools directly
mcp__plugin_context7_context7__query-docs (❌ Don't do this)
```

### Benefits

- Prevents using deprecated APIs or outdated patterns
- Ensures version-specific accuracy
- Reduces debugging time from outdated examples
- Provides official, current code examples

## Web Search for 2026 Best Practices

Before starting any new implementation, ALWAYS web search for current best practices and 2026 patterns:

### When to Web Search

- Before implementing any new feature or component
- When choosing between multiple architectural approaches
- Before selecting libraries, frameworks, or tools
- When implementing security-sensitive functionality
- Before performance optimization strategies

### Search Strategy

1. **Current Year Focus**: Include "2026" in search queries to get latest practices
2. **Best Practices**: Search for "best practices 2026" for the specific technology
3. **Security Considerations**: Always check for current security recommendations
4. **Performance Patterns**: Look for modern performance optimization techniques

### Benefits

- Ensures implementation follows current industry standards
- Incorporates latest security practices
- Leverages modern performance optimizations
- Avoids deprecated or discouraged patterns

## Default Delegation

Before doing any non-trivial work directly, ask: "can a subagent do this?" Default answer is YES. Reserve direct work (in Opus) for: planning, routing decisions, final synthesis, single-line conversational answers, and trivial single-file edits (<20 lines). Everything else — research, multi-file reads, implementation, refactors, test writing — goes to a subagent following the Subagent Policy model table below.

## Subagent Policy

### Model Selection
| Agent Type | Model | Why |
|---|---|---|
| Explore | `haiku` | Cheap, good for research/search |
| Plan | `opus` | Best reasoning for architecture |
| All others | `sonnet` | Balance of cost and capability |

**Never** leave model unset — it defaults to the parent model which may be opus.

### Context Offloading
Proactively spawn parallel Explore (haiku) subagents to keep the main context clean. Do NOT research inline when a subagent can do it.

**Always offload to subagents:**
- Web searches, documentation lookups, Context7 queries
- Reading large/multiple files for research or exploration
- Codebase-wide searches spanning many files
- Codebase-wide replacements (renaming, refactoring across files)
- Comparing multiple approaches or libraries

**Spawn multiple agents in parallel** when the task involves independent research tracks (e.g., "research X vs Y" → 2 agents, one per topic).

## Modern Development Tools

Prefer modern tools when setting up projects:

- **Python**: Use `uv` (instead of pip/venv)
- **Node.js versions**: Use `fnm` (instead of nvm)
- **JavaScript/TypeScript**: Use `bun` (instead of npm/yarn/pnpm)
