local M = {
  "numToStr/Comment.nvim",
  lazy = false,
  commit = "0236521ea582747b58869cb72f70ccfa967d2e89",
  --dependencies = {
  --  {
  --    "JoosepAlviste/nvim-ts-context-commentstring",
  --    event = "VeryLazy",
  --    commit = "92e688f013c69f90c9bbd596019ec10235bc51de",
  --  },
  --},
}

function M.config()
  local wk = require "which-key"
  wk.register {
    ["<leader>/"] = { "<Plug>(comment_toggle_linewise_current)", "Comment" },
  }

  wk.register {
    ["<leader>/"] = { "<Plug>(comment_toggle_linewise_visual)", "Comment", mode = "v" },
  }

  --vim.g.skip_ts_context_commentstring_module = true
  -----@diagnostic disable: missing-fields
  --require("ts_context_commentstring").setup {
  --  enable_autocmd = false,
  --}

  ---@diagnostic disable: missing-fields
  require("Comment").setup {
    --pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
  }
end

return M
