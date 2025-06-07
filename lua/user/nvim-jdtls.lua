local M = {
  "mfussenegger/nvim-jdtls",
  -- tag = "0.2.0",
  branch = "master",
  dependencies = {
    {
      "ray-x/lsp_signature.nvim",
      -- event = "VeryLazy",
      event = "InsertEnter",
      tag = "v0.3.1",
    },
  },
}


function M.config()
end

return M
