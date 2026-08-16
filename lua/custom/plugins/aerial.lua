-- Aerial.nvim
-- Code outline window for navigating between methods, classes, properties, etc.
-- Ideal para C# con métodos largos: permite saltar rápidamente entre símbolos
-- y ver la estructura del archivo en un panel lateral.

return {
  'stevearc/aerial.nvim',
  opts = {
    -- Layout config
    layout = {
      default_direction = 'right',
      max_width = { 50, 0.2 },
      min_width = 30,
    },
    -- Show all symbol kinds (works for any language)
    filter_kind = false,
    -- Show line numbers in aerial
    show_linenumbers = false,
    -- Show nested symbols as a tree (collapse big classes)
    nest_under_parents = true,
    -- Collapse by default if more than this many levels
    collapse_levels = 3,
    -- Treesitter is preferred, but falls back to LSP
    sources = { 'treesitter', 'lsp' },
    -- Open aerial automatically when entering a buffer (optional, disable if too noisy)
    open_automatic = false,
  },
  keys = {
    -- Toggle aerial panel
    { '<leader>ao', '<cmd>AerialToggle!<cr>', desc = 'Aerial (Code Outline)' },
    -- Navigate between symbols
    { ']m', '<cmd>AerialNext<cr>', desc = 'Next method/symbol' },
    { '[m', '<cmd>AerialPrev<cr>', desc = 'Previous method/symbol' },
  },
}