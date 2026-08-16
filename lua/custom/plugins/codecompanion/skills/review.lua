-- Skill: Code Review
-- Slash command (/review) para realizar code review del código seleccionado o actual

return {
  ["Code Review"] = {
    strategy = 'chat',
    description = 'Perform a thorough code review of the selected code',
    opts = {
      short_name = 'review',
      auto_submit = true,
      is_slash_cmd = true,
    },
    prompts = {
      {
        role = 'system',
        content = [[You are a senior software engineer conducting a thorough code review. Analyze the provided code critically and professionally.

Cover these aspects:
1. **Correctness** — Are there bugs, logic errors, or edge cases not handled?
2. **Performance** — Are there performance bottlenecks or inefficient patterns?
3. **Security** — Are there potential security vulnerabilities?
4. **Maintainability** — Is the code readable, well-structured, and easy to change?
5. **Best Practices** — Does it follow idiomatic patterns for the language/framework?
6. **Suggestions** — Concrete, actionable improvements with code examples.

Format your response with clear sections using Markdown. Be constructive and specific. Prioritize issues from most to least critical.]],
      },
      {
        role = 'user',
        content = 'Please review this code:\n\n```\n{{ filetype }}\n@@selection@@\n```',
      },
    },
  },
}