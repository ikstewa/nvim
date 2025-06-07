-- lua/config/profile.lua (new file)
local M = {}

function M.startup()
  local startuptime = vim.fn.reltime()
  
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimStarted",
    callback = function()
      local elapsed = vim.fn.reltimestr(vim.fn.reltime(startuptime))
      local startup_time = string.format("%10.3f", elapsed:gsub(",", "."))
      vim.notify("Neovim loaded in " .. startup_time .. " milliseconds")
      
      -- Save to log file for tracking improvements
      local file = io.open(vim.fn.stdpath("cache") .. "/startup_log.txt", "a")
      if file then
        local date = os.date("%Y-%m-%d %H:%M:%S")
        file:write(date .. " - " .. startup_time .. "ms\n")
        file:close()
      end
    end,
  })
end

return M
