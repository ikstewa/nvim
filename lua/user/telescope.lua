local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

local actions = require "telescope.actions"

telescope.setup {
  defaults = {

    -- prompt_prefix = " ",
    selection_caret = " ",
    path_display = { "smart" },
    file_ignore_patterns = { ".git/", "node_modules" },

    mappings = {
      i = {
        -- ["<Down>"] = actions.cycle_history_next,
        -- ["<Up>"] = actions.cycle_history_prev,
        -- ["<C-j>"] = actions.move_selection_next,
        -- ["<C-k>"] = actions.move_selection_previous,
      },
    },
  },
  pickers = {
    oldfiles = {
      -- sort_lastused = true,
      cwd_only = true,
    },
    -- find_files = {
    --   hidden = true,
    --   find_command = {
    --     'rg',
    --     '--files',
    --     '--color',
    --     'never',
    --     '--ignore-file',
    --     vim.env.XDG_CONFIG_HOME .. '/ripgrep/ignore',
    --   },
    -- },
    live_grep = {
      -- path_display = { 'shorten' },
      -- mappings = {
      --   i = {
      --     -- FIXME: Consider using extension/folder filters: https://github.com/JoosepAlviste/dotfiles/blob/master/config/nvim/lua/j/plugins/telescope_custom_pickers.lua#L57
      --     ['<c-f>'] = custom_pickers.actions.set_extension,
      --     ['<c-l>'] = custom_pickers.actions.set_folders,
      --   },
      -- },
    },
  },
}

-- Enable telescope fzf native, if installed
require('telescope').load_extension('fzf')

-- Search emojis in telescope
require('telescope').load_extension('emoji')

-- -- Use telescope for select
-- require("telescope").load_extension("ui-select")

require("telescope").load_extension("repo")
