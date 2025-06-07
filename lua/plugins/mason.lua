local M = {
  "williamboman/mason-lspconfig.nvim",
  tag = "v1.32.0",
  -- commit = "e7b64c11035aa924f87385b72145e0ccf68a7e0a",
  dependencies = {
    {
      "williamboman/mason.nvim",
      tag = "v1.11.0",
    },
    -- "williamboman/mason.nvim",
    "nvim-lua/plenary.nvim",
  },
}

M.servers = {
  "lua_ls",
  "cssls",
  "html",
  -- "tsserver",
  "astro",
  "pyright",
  "ruff",
  "bashls",
  "jsonls",
  "yamlls",
  "marksman",
  "tailwindcss",
  "gopls",
}

function M.config()
  require("mason").setup {
    ui = {
      border = "rounded",
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  }
  require("mason-lspconfig").setup {
    ensure_installed = M.servers,
  }
end

return M
