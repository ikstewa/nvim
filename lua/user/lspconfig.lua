local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  tag = "v0.1.7",
  dependencies = {
    {
      "folke/neodev.nvim",
      tag = "v2.5.2",
    },
  },
}

function M.common_capabilities()
  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then
    return cmp_nvim_lsp.default_capabilities()
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  }

  return capabilities
end

function M.config()
  local lspconfig = require "lspconfig"
  local icons = require "user.icons"

  local servers = {
    "lua_ls",
    "cssls",
    "html",
    "tsserver",
    "astro",
    "pyright",
    "ruff_lsp",
    "bashls",
    "jsonls",
    "yamlls",
    "marksman",
    "tailwindcss",
  }

  local default_diagnostic_config = {
    signs = {
      active = true,
      values = {
        { name = "DiagnosticSignError", text = icons.diagnostics.Error },
        { name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
        { name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
        { name = "DiagnosticSignInfo", text = icons.diagnostics.Information },
      },
    },
    virtual_text = false,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(default_diagnostic_config)

  for _, sign in ipairs(vim.tbl_get(vim.diagnostic.config(), "signs", "values") or {}) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
  end

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
  require("lspconfig.ui.windows").default_options.border = "rounded"

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)

      local opts = { noremap = true, silent = true }
      local keymap = vim.api.nvim_buf_set_keymap
      keymap(ev.buf, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
      -- keymap(ev.buf, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
      keymap(ev.buf, "n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
      keymap(ev.buf, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
      -- keymap(ev.buf, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
      keymap(ev.buf, "n", "gI", "<cmd>Telescope lsp_implementations<CR>", opts)
      -- keymap(ev.buf, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
      keymap(ev.buf, "n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
      keymap(ev.buf, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)

    end,
  })

  for _, server in pairs(servers) do
    local opts = {
      capabilities = M.common_capabilities(),
    }

    local require_ok, settings = pcall(require, "user.lspsettings." .. server)
    if require_ok then
      opts = vim.tbl_deep_extend("force", settings, opts)
    end

    if server == "lua_ls" then
      require("neodev").setup {}
    end

    lspconfig[server].setup(opts)
  end
end

return M
