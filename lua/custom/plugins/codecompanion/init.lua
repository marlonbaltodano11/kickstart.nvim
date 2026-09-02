-- CodeCompanion main configuration
-- Ensambla todos los módulos: adapters, strategies, rules, prompt_library, skills, extensions

return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    { 'stevearc/dressing.nvim', opts = {} },
    'ravitemer/codecompanion-history.nvim',
  },
  opts = {
    adapters = {
      http = require('custom.plugins.codecompanion.adapters'),
    },
    interactions = require('custom.plugins.codecompanion.interactions'),
    rules = require('custom.plugins.codecompanion.rules'),
    prompt_library = vim.tbl_deep_extend('force', require('custom.plugins.codecompanion.prompts'), require('custom.plugins.codecompanion.skills')),
    extensions = require('custom.plugins.codecompanion.extensions'),
  },
  keys = require('custom.plugins.codecompanion.keymaps'),
}