-- Main entry point

-- require("config.profile").startup()

-- Only load the absolute minimum at startup
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Delay loading of core modules
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("config.autocmds")
  end,
})

-- Load core configuration
require("config.options")
require("config.keymaps")

-- Setup plugins
require("config.lazy").setup()
