# How to Build a Coding Agent

> Distilled from [Geoffrey Huntley's workshop](https://ghuntley.com/agent/) — August 2025

---

## The Core Truth

> **It's not that hard to build a coding agent.**
>
> It's 300 lines of code running in a loop with LLM tokens.
>
> You just keep throwing tokens at the loop, and then you've got yourself an agent.

Cursor, Windsurf, Claude Code, GitHub Copilot, Amp — they're all just a small number of lines of code running in a loop of LLM tokens. The model does all the heavy lifting.

---

## Why Build Your Own?

Building your own coding agent transforms you:

| Before | After |
|--------|-------|
| Consumer of AI | Producer of AI |
| Evaluating 5 vendors | Understanding fundamentals |
| Dependent on tools | Can automate anything |
| Waiting for features | Building what you need |

> *"If you haven't built your own coding agent yet — please do."*

This knowledge is now **fundamental** — like knowing what a primary key is. Employers are looking for engineers who understand this loop.

---

## Key Concepts

### 1. Not All LLMs Are Agentic

Models have specializations, like cars:

| Quadrant | Characteristics | Use For |
|----------|-----------------|---------|
| **High Safety** | Ethics-aligned, guardrails | Production code |
| **Low Safety** | Fewer restrictions | Security research |
| **Oracle** | Deep thinking, summarization | Planning, review |
| **Agentic** | Biases toward action, tool-calling | Autonomous work |

**Agentic models** (Claude Sonnet, Kimi K2) are trained to chase tool calls like a squirrel chases nuts. They don't overthink — they act incrementally.

> *"The first robot was designed to chase tennis balls. The first digital robot chases tool calls."*

### 2. Context Windows Are Small

Think of context windows like a Commodore 64 — limited memory.

| Advertised | Usable | Why |
|------------|--------|-----|
| 200K tokens | ~176K | System prompt + harness overhead |

**Cardinal rule**: The more you allocate, the worse performance gets.

- Don't install too many MCP servers
- Consider aggregate context allocation of all tools
- Clear context between activities

> *"Less is more, folks. Less is more."*

### 3. One Activity Per Context Window

If you:
1. Build a backend API controller
2. Research facts about meerkats
3. Ask it to redesign the website

...the website might include meerkats and API references.

**Always clear context between distinct activities.**

---

## The Agent Loop

```
┌─────────────────────────────────────────────────────────────┐
│                    THE INFERENCING LOOP                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User Input                                                  │
│      │                                                       │
│      ▼                                                       │
│  ┌──────────────┐                                           │
│  │  Allocate to │◀──────────────────────────────┐           │
│  │   Response   │                               │           │
│  └──────┬───────┘                               │           │
│         │                                        │           │
│         ▼                                        │           │
│  ┌──────────────┐                               │           │
│  │   Send for   │                               │           │
│  │  Inferencing │                               │           │
│  └──────┬───────┘                               │           │
│         │                                        │           │
│         ▼                                        │           │
│  ┌──────────────┐     Yes    ┌──────────────┐   │           │
│  │ Tool Call?   │───────────▶│ Execute Tool │───┘           │
│  └──────┬───────┘            └──────────────┘               │
│         │ No                                                 │
│         ▼                                                    │
│  ┌──────────────┐                                           │
│  │    Output    │                                           │
│  └──────────────┘                                           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

That's it. Every coding agent follows this pattern.

---

## The Five Primitives

Every coding agent is built from these five tools:

### 1. Read File Tool

Reads file contents into the context window.

```go
var ReadFileDefinition = ToolDefinition{
    Name:        "read_file",
    Description: "Read the contents of a given relative file path. Use this when you want to see what's inside a file. Do not use this with directory names.",
    InputSchema: ReadFileInputSchema,
    Function:    ReadFile,
}
```

### 2. List Files Tool

Lists files and directories in a given path.

```go
var ListFilesDefinition = ToolDefinition{
    Name:        "list_files",
    Description: "List files and directories at a given path. If no path is provided, lists files in the current directory.",
    InputSchema: ListFilesInputSchema,
    Function:    ListFiles,
}
```

### 3. Bash Tool

Executes shell commands on the computer.

```go
var BashDefinition = ToolDefinition{
    Name:        "bash",
    Description: "Execute a bash command and return its output. Use this to run shell commands.",
    InputSchema: BashInputSchema,
    Function:    Bash,
}
```

### 4. Edit File Tool

Applies edits to files based on inference results.

```go
var EditFileDefinition = ToolDefinition{
    Name:        "edit_file",
    Description: "Edit a file by replacing old content with new content.",
    InputSchema: EditFileInputSchema,
    Function:    EditFile,
}
```

### 5. Code Search Tool

Searches for patterns in code. **No magic here** — nearly every coding tool uses `ripgrep` under the hood.

```go
var CodeSearchDefinition = ToolDefinition{
    Name: "code_search",
    Description: `Search for code patterns using ripgrep (rg).
Use this to find code patterns, function definitions, variable usage, or any text in the codebase.`,
    InputSchema: CodeSearchInputSchema,
    Function:    CodeSearch,
}
```

---

## Tool Registration Pattern

A tool is just a function with a billboard that nudges the LLM's latent space to invoke it:

```
┌────────────────────────────────────────┐
│           TOOL REGISTRATION            │
├────────────────────────────────────────┤
│  Name: "get_weather"                   │
│  Description: "Get weather for a       │
│               location..."             │
│  InputSchema: { location: string }     │
│  Function: GetWeather()                │
└────────────────────────────────────────┘
         │
         ▼
    LLM sees description
         │
         ▼
    User asks about weather
         │
         ▼
    LLM calls: get_weather("Melbourne")
```

This is what MCP servers are. Functions with descriptions. That's it.

---

## Wiring in Other LLMs

Want higher-level reasoning to check the squirrel's work?

Wire other LLMs in as tools:

```
┌─────────────────────────────────────────────────────────────┐
│                    AGENTIC LLM (Sonnet)                      │
│                         │                                    │
│    ┌───────────────────┼───────────────────┐                │
│    │                   │                   │                │
│    ▼                   ▼                   ▼                │
│ ┌──────┐          ┌────────┐         ┌──────────┐          │
│ │ Bash │          │ Oracle │         │ Read File│          │
│ │ Tool │          │ (GPT)  │         │   Tool   │          │
│ └──────┘          └────────┘         └──────────┘          │
│                        │                                    │
│                        ▼                                    │
│              Guidance, planning,                            │
│              work verification                              │
└─────────────────────────────────────────────────────────────┘
```

This is what Amp does — Claude Sonnet can call GPT ("the Oracle") for guidance, checking work progress, and research/planning.

---

## The Harness Prompt

Everything after the five primitives is **prompt tuning**:

| Component | Purpose |
|-----------|---------|
| Tool registrations | What the agent can do |
| OS information | PowerShell vs bash |
| Operating instructions | How the agent should behave |
| Constraints | What it should NOT do |

LLMs are non-deterministic. Instructions are guidance, not guarantees. Through prompt evaluation, tuning, and understanding model behavior, you develop effective prompts.

---

## Workshop Resources

- **Source code**: [github.com/ghuntley/how-to-build-a-coding-agent](https://github.com/ghuntley/how-to-build-a-coding-agent)
- **Open source agents**: [SST OpenCode](https://github.com/sst/opencode)
- **Minimal agent**: [mini-swe-agent](https://github.com/SWE-agent/mini-swe-agent) — 100 lines, 68% on SWE-bench
- **Leaked prompts**: [system-prompts-and-models-of-ai-tools](https://github.com/x1xhlol/system-prompts-and-models-of-ai-tools)

---

## The Two Classes of Engineers

There is now a divide:

### Class 1: Consumers
- Rejecting AI entirely, OR
- Using Claude Code/Cursor to accelerate brick-by-brick building

### Class 2: Producers
- Understanding LLMs as a new programmable computer
- Building their own coding agents
- Automating their job function

> *"Your coworkers are going to take your job, not AI."*

If your coworkers are hopping between multiple agents during meetings, and you're not — you're falling behind.

---

## The Transformation

| Old World | New World |
|-----------|-----------|
| Plan for a week | Turn idea into execution by speaking |
| Research spike | Agent researches while you work |
| Manual coding | Concurrent agent execution |
| Waiting for builds | Work happening while you're AFK |

> *"The next time you're on a Zoom call, consider that you could've had an agent building the work you're planning during that call."*

---

## Key Quotes

> *"It's 300 lines of code running in a loop with LLM tokens."*

> *"The model does all the heavy lifting here, folks. It's the model that does it all."*

> *"LLMs are a new form of programmable computer."*

> *"Go forward and build."*

---

## How This Maps to Ralphus

| Workshop Concept | Ralphus Implementation |
|------------------|------------------------|
| The Loop | `lib/loop_core.sh` + `opencode run` |
| Five Primitives | OpenCode's built-in tools |
| Harness Prompt | Variant prompts (`PROMPT_*.md`) |
| Tool Registration | Prompt templates with @ file references |
| Context Clearing | Fresh context each iteration |
| Oracle | Subagent delegation (Opus for reasoning) |

Ralphus IS this loop — orchestrating OpenCode (the agent) in iterations with specs and tracking files.
