-- Prompt: Generate Commit
-- Basado en el diff de git, genera un commit semántico

return {
  ["Generate Commit"] = {
    strategy = 'chat',
    description = 'Generate a semantic commit command based on a git diff',
    opts = {
      short_name = 'commit',
      auto_submit = false,
      is_slash_cmd = false,
    },
    prompts = {
      {
        role = 'system',
        content = [[You are an expert developer. Your task is to write clear, concise commit messages based on a git diff following the 'Conventional Commits' specification (e.g., feat, fix, refactor, docs, chore).
You must explain the WHAT and the WHY, not just the HOW.

CRITICAL RULE: You must output ONLY the final `git commit` CLI command. Do NOT output a raw text block. For any multi-line commit messages (like adding a body or footer), you MUST use multiple `-m` flags instead of actual line breaks.
Example format: `git commit -m "feat: add user authentication" -m "This introduces the JWT-based auth flow to secure the API endpoints."`

Do not provide any introductory text, markdown formatting, or explanations. Just the exact command.]],
      },
      {
        role = 'user',
        content = '@{run_command} Please run the necessary commands to analyze my git diff and generate the appropriate git commit command\n\n',
      },
    },
  },
}