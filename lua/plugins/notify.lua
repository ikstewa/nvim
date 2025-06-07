local M = {
  "rcarriga/nvim-notify",
  tag = "v3.15.0",
}

function M.config()
  local notify = require("notify")

  vim.notify = notify
  notify.setup({
    stages = "fade_in_slide_out"
  })
end

return M
