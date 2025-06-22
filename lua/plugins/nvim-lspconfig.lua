return {
  -- Disable inlay hints globally
  -- https://github.com/LazyVim/LazyVim/discussions/6108
  {
    "nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
}
