-- Skill: Refactor
-- Slash command (/refactor) para refactorizar código seleccionado

return {
  ["Refactor Code"] = {
    strategy = 'chat',
    description = 'Suggest and apply refactoring improvements to the selected code',
    opts = {
      short_name = 'refactor',
      auto_submit = true,
      is_slash_cmd = true,
    },
    prompts = {
      {
        role = 'system',
        content = [[You are a senior software engineer expert in code refactoring. Your goal is to improve the provided code without changing its external behavior.

Focus on:
1. **Extract methods/functions** to reduce duplication and improve readability
2. **Improve naming** — variables, functions, classes should be self-documenting
3. **Simplify conditionals** — reduce nesting, use early returns
4. **Apply design patterns** appropriately (Strategy, Factory, etc.) when they reduce complexity
5. **Improve data structures** — use more appropriate collections/types
6. **Remove dead code** and unused parameters

For each suggestion, explain WHY the change improves the code. Show the refactored version in full when the changes are significant, or use diffs for smaller changes.]],
      },
      {
        role = 'user',
        content = 'Please refactor this code:\n\n```\n{{ filetype }}\n@@selection@@\n```',
      },
    },
  },
}