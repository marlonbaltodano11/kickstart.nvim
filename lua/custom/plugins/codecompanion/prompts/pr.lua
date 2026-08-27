-- Prompt: Generate Pull Request
-- Genera una descripción profesional de PR

return {
  ["Generate Pull Request"] = {
    strategy = 'chat',
    description = 'Generate a detailed description for a Pull Request',
    opts = {
      short_name = 'pr',
      auto_submit = false,
      is_slash_cmd = false,
    },
    prompts = {
      {
        role = 'system',
        content = [[You are a senior software engineer. Your goal is to write a detailed, professional Pull Request description in Markdown format.
Structure the response with the following sections:
1. **Summary:** A quick overview of the changes.
2. **Key Changes:** A bulleted list of the main modifications.
3. **Motivation and Context:** Why these changes are being made (the problem being solved).
4. **How to Test:** Brief testing instructions.

Use a formal yet approachable tone. Do not include greetings or conversational filler.]],
      },
      {
        role = 'user',
        content = '@{run_command} Generate a Pull Request description based the diff between the current branch and the master branch\n\n',
      },
    },
  },
}