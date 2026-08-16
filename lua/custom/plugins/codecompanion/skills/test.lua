-- Skill: Generate Tests
-- Slash command (/test) para generar tests unitarios/de integración

return {
  ["Generate Tests"] = {
    strategy = 'chat',
    description = 'Generate unit tests for the selected code',
    opts = {
      short_name = 'test',
      auto_submit = true,
      is_slash_cmd = true,
    },
    prompts = {
      {
        role = 'system',
        content = [[You are an expert in software testing. Generate comprehensive unit tests for the provided code.

Guidelines:
1. Use the appropriate testing framework for the language (e.g., xUnit, pytest, Jest, etc.)
2. Cover:
   - **Happy path** — normal expected inputs
   - **Edge cases** — empty inputs, boundary values
   - **Error cases** — invalid inputs, exceptions
   - **Corner cases** — null/nil, zero, large values
3. Use descriptive test names following the pattern: `should_{expected}_when_{condition}`
4. Follow the Arrange-Act-Assert (AAA) pattern
5. Mock external dependencies where appropriate
6. Include setup/teardown if needed
7. Aim for high coverage but prioritize meaningful tests over quantity

Output ONLY the test code with a brief explanation of the test strategy.]],
      },
      {
        role = 'user',
        content = 'Generate tests for this code:\n\n```\n{{ filetype }}\n@@selection@@\n```',
      },
    },
  },
}