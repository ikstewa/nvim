local M = {}

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
	return
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.update_capabilities(M.capabilities)

M.setup = function()
	local signs = {

		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		virtual_text = false, -- disable virtual text
		signs = {
			active = signs, -- show signs
		},
		update_in_insert = true,
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

	vim.diagnostic.config(config)

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
	})
end

local function lsp_keymaps(bufnr)
	local opts = { noremap = true, silent = true }
	local keymap = vim.api.nvim_buf_set_keymap
	keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	keymap(bufnr, "n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
	keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	keymap(bufnr, "n", "gI", "<cmd>Telescope lsp_implementations<CR>", opts)
	keymap(bufnr, "n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
	keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	keymap(bufnr, "n", "<leader>li", "<cmd>LspInfo<cr>", opts)
	keymap(bufnr, "n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
	keymap(bufnr, "n", "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", opts)
	keymap(bufnr, "n", "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", opts)
	keymap(bufnr, "n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
  keymap(bufnr, "n", "<leader>lf", "<cmd>lua vim.lsp.buf.format{ async = true }<cr>", opts)
	keymap(bufnr, "n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	keymap(bufnr, "n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
end

-- Sample Lens:
-- {
--   fullName = "com.kollective.tenant.PortalNetworkLocationIntegrationTest#canAddNewCategory",
--   id = "tenant-integration-tests@com.kollective.tenant.PortalNetworkLocationIntegrationTest#canAddNewCategory",
--   jdtHandler = "=tenant-integration-tests/src\\/integrationTest\\/java=/gradle_scope=/integrationTest=/=/gradle_used_by_scope=/integrationTest=/=/test=/true=/<com.kollective.tenant{PortalNetworkLocationIntegrationTest.java[PortalNetworkLocationIntegrationTest~canAddNewCategory",
--   label = "canAddNewCategory()",
--   projectName = "tenant-integration-tests",
--   range = {
--     ["end"] = {
--       character = 3,
--       line = 487
--     },
--     start = {
--       character = 7,
--       line = 421
--     }
--   },
--   testKind = 0,
--   testLevel = 6,
--   uri = "file:///Users/istewart/dev/services/tenant/tenant-integration-tests/src/integrationTest/java/com/kollective/tenant/PortalNetworkLocationIntegrationTest.java"
-- }
function pick_test_method_async(cb)
  local jdtls_dap = require'jdtls.dap'

  local bufnr = vim.api.nvim_get_current_buf()
  local context = jdtls_dap.experimental.make_context(bufnr)

  jdtls_dap.experimental.fetch_lenses(context, function(lenses)

    return require('jdtls.ui').pick_one_async(
      lenses[1].children,
      'Tests> ',
      function(lens) return lens.label end,
      function(lens)
        if not lens then
          return
        end
        cb(lens)
      end
    )
  end)
end

local function lsp_keymaps_java(bufnr)
	local opts = { noremap = true, silent = true }
	local keymap = vim.api.nvim_buf_set_keymap

  keymap(bufnr, "n", "<leader>jo", "<Cmd>lua require'jdtls'.organize_imports()<CR>", { desc = '[J]ava [o]organize imports' })
  keymap(bufnr, "n", "<leader>jv", "<Cmd>lua require('jdtls').extract_variable()<CR>", { desc = '[J]ava extends [v]variable' })
  keymap(bufnr, "n", "<leader>jc", "<Cmd>lua require('jdtls').extract_constant()<CR>", { desc = '[J]ava extract [c]constant' })
  keymap(bufnr, "n", "<leader>jt", "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", { desc = '[J]ava run method [t]est' })
  keymap(bufnr, "n", "<leader>jT", "<Cmd>lua require'jdtls'.test_class()<CR>", { desc = '[J]ava run class [T]ests' })
  keymap(bufnr, "n", "<leader>ju", "<Cmd>JdtUpdateConfig<CR>", opts)

  keymap(bufnr, "v", "<leader>jv", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", { desc = '[J]ava extract [v]ariable' })
  keymap(bufnr, "v", "<leader>jc", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", { desc = '[J]ava extract [c]onstant' })
  keymap(bufnr, "v", "<leader>jm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", { desc = '[J]ava extract [m]ethod' })

  vim.keymap.set('n', "<leader>jI", function()

    -- local project_name = vim.split(vim.fn.expand('%:h'), '/')[1]
    -- local class_name = require('jdtls.util').resolve_classname()
    -- local command = string.format("./gradlew :%s:integrationTest --tests '%s' --debug-jvm", project_name, class_name)
    -- vim.notify(command)

    pick_test_method_async(function(lens)
      -- vim.notify(vim.inspect(lens))
      local command = string.format(
        "./gradlew :%s:integrationTest --tests '%s' --debug-jvm",
        lens.projectName,
        lens.fullName:gsub("#", "."))

      -- vim.notify(command)
      require('toggleterm').exec(command)
    end)
  end, {buffer = bufnr, desc = '[J]ava run [I]ntegration test'} )
end

M.on_attach = function(client, bufnr)
	lsp_keymaps(bufnr)

  vim.notify("LSP Client: " .. client.name)

	if client.name == "tsserver" then
		client.server_capabilities.documentFormattingProvider = false
	end

	if client.name == "lua_ls" then
		client.server_capabilities.documentFormattingProvider = false
	end

  if client.name == "jdtls" then
    lsp_keymaps_java(bufnr)

    vim.lsp.codelens.refresh()
    if JAVA_DAP_ACTIVE then
      require("jdtls").setup_dap() --[[ { hotcodereplace = "auto" } ]]
      require("jdtls.dap").setup_dap_main_class_configs()

      require"dap".configurations.java = {
        {
          type = 'java',
          request = 'attach',
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          port = 5005,
        },
      }

    end
    client.server_capabilities.document_formatting = false
    client.server_capabilities.textDocument.completion.completionItem.snippetSupport = false
  end

  if client.name == "rust_analyzer" then
    -- Note: Rust is a snowflake and is configured using rust-tools
    -- see lsp/rust-tools.lua

    -- vim.notify("Using Rust")
  end

	local status_ok, illuminate = pcall(require, "illuminate")
	if not status_ok then
		return
	end
	illuminate.on_attach(client)
end

return M
