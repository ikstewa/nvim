vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.cmdheight = 2 -- more space in the neovim command line for displaying messages

local status_jdtls, jdtls = pcall(require, "jdtls")
if not status_jdtls then
  vim.notify("Failed to load jdtls")
  return
end
local status_jdtls_dap, jdtls_dap = pcall(require, "jdtls.dap")
if not status_jdtls_dap then
  vim.notify("Failed to load jdtls.dap")
  return
end
local status_jdtls_setup, jdtls_setup = pcall(require, "jdtls.setup")
if not status_jdtls_setup then
  vim.notify("Failed to load jdtls.setup")
  return
end

-- Determine OS
local home = os.getenv "HOME"
if vim.fn.has "mac" == 1 then
  CONFIG_OS = "mac"
elseif vim.fn.has "unix" == 1 then
  CONFIG_OS = "linux"
else
  print "Unsupported system"
end

-- Find root of project
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml"--[[ , "build.gradle" ]] }
local root_dir = jdtls_setup.find_root(root_markers)
if root_dir == "" then
  vim.notify("Failed to determine project root path")
  return
end
-- local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name

local path_to_mason_packages = home .. "/.local/share/nvim/mason/packages"
local path_to_jdtls = path_to_mason_packages .. "/jdtls"
local path_to_jdebug = path_to_mason_packages .. "/java-debug-adapter"
local path_to_jtest = path_to_mason_packages .. "/java-test"

local path_to_config = path_to_jdtls .. "/config_" .. CONFIG_OS
local lombok_path = path_to_jdtls .. "/lombok.jar"
-- local path_to_jar = path_to_jdtls .. "/plugins/org.eclipse.equinox.launcher_1.6.700.v20231214-2017.jar"
local path_to_jar = vim.fn.glob(path_to_jdtls .. "/plugins/org.eclipse.equinox.launcher_*.jar")

local bundles = {
  vim.fn.glob(path_to_jdebug .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(path_to_jtest .. "/extension/server/*.jar", true), "\n"))

-- LSP settings for Java.
local on_attach = function(_, bufnr)
  jdtls.setup_dap({ hotcodereplace = "auto" })
  jdtls_dap.setup_dap_main_class_configs()
  jdtls_setup.add_commands()

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
    vim.lsp.buf.format()
  end, { desc = "Format current buffer with LSP" })

  require("lsp_signature").on_attach({
    bind = true,
    padding = "",
    handler_opts = {
      border = "rounded",
    },
    hint_prefix = "󱄑 ",
  }, bufnr)

  -- FIXME: Setup lspsaga???
  -- require 'lspsaga'.init_lsp_saga()

end

local capabilities = {
  workspace = {
    configuration = true
  },
  textDocument = {
    completion = {
      completionItem = {
        snippetSupport = true
      }
    }
  }
}

local config = {
  flags = {
    allow_incremental_sync = true,
  }
}

config.cmd = {
  "java", -- or '/path/to/java17_or_newer/bin/java'
  -- depends on if `java` is in your $PATH env variable and if it points to the right version.

  "-Declipse.application=org.eclipse.jdt.ls.core.id1",
  "-Dosgi.bundles.defaultStartLevel=4",
  "-Declipse.product=org.eclipse.jdt.ls.core.product",
  "-Dlog.protocol=true",
  "-Dlog.level=ALL",
  "-Xmx1g",
  "-javaagent:" .. lombok_path,
  "--add-modules=ALL-SYSTEM",
  "--add-opens",
  "java.base/java.util=ALL-UNNAMED",
  "--add-opens",
  "java.base/java.lang=ALL-UNNAMED",

  "-jar",
  path_to_jar,

  "-configuration",
  path_to_config,

  "-data",
  workspace_dir,
}

config.settings = {
  java = {
    references = {
      includeDecompiledSources = true,
    },
    format = {
      -- Set this to true to use jdtls as your formatter
      enabled = true,
      settings = {
        url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
        profile = "GoogleStyle",
      },
    },
    eclipse = {
      downloadSources = true,
    },
    maven = {
      downloadSources = true,
    },
    signatureHelp = { enabled = true },
    contentProvider = { preferred = "fernflower" },
    implementationsCodeLens = {
    	enabled = true,
    },
    referencesCodeLens = {
      enabled = true,
    },
    completion = {
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.hamcrest.CoreMatchers.*",
        "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.mockito.Mockito.*",
      },
      filteredTypes = {
        "com.sun.*",
        "io.micrometer.shaded.*",
        "java.awt.*",
        "jdk.*",
        "sun.*",
      },
      importOrder = {
        "java",
        "javax",
        "com",
        "org",
      },
    },
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      },
    },
    codeGeneration = {
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        -- flags = {
        -- 	allow_incremental_sync = true,
        -- },
      },
      useBlocks = true,
    },
    -- configuration = {
    --     updateBuildConfiguration = "interactive",
    --     runtimes = {
    --         {
    --             name = "java-17-openjdk",
    --             path = "/usr/lib/jvm/default-runtime/bin/java"
    --         }
    --     }
    -- }
    -- project = {
    -- 	referencedLibraries = {
    -- 		"**/lib/*.jar",
    -- 	},
    -- },
  },
}

config.on_attach = on_attach
config.capabilities = capabilities
config.on_init = function(client, _)
  client.notify('workspace/didChangeConfiguration', { settings = config.settings })
end

local extendedClientCapabilities = require 'jdtls'.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

config.init_options = {
  bundles = bundles,
  extendedClientCapabilities = extendedClientCapabilities,
}

-- Start Server
require('jdtls').start_or_attach(config)

-- -- Set Java Specific Keymaps
-- require("jdtls.keymaps")







-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--   pattern = { "*.java" },
--   callback = function()
--     vim.lsp.codelens.refresh()
--   end,
-- })


vim.cmd "command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)"
vim.cmd "command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_set_runtime JdtSetRuntime lua require('jdtls').set_runtime(<f-args>)"
vim.cmd "command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()"
vim.cmd "command! -buffer JdtBytecode lua require('jdtls').javap()"

-- -- Shorten function name
-- local keymap = vim.keymap.set
-- -- Silent keymap option
-- local opts = { silent = true }
--
-- Moved to handlers.lua for buffer only mappings
-- keymap("n", "<leader>jo", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
-- keymap("n", "<leader>jv", "<Cmd>lua require('jdtls').extract_variable()<CR>", opts)
-- keymap("n", "<leader>jc", "<Cmd>lua require('jdtls').extract_constant()<CR>", opts)
-- keymap("n", "<leader>jt", "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", opts)
-- keymap("n", "<leader>jT", "<Cmd>lua require'jdtls'.test_class()<CR>", opts)
-- keymap("n", "<leader>ju", "<Cmd>JdtUpdateConfig<CR>", opts)
--
-- keymap("v", "<leader>jv", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", opts)
-- keymap("v", "<leader>jc", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", opts)
-- keymap("v", "<leader>jm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts)
