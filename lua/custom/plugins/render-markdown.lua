-- Render Markdown
-- Plugin general para renderizar Markdown en Neovim
-- Se activa en buffers markdown y codecompanion

return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown', 'codecompanion' },
  opts = {},
}