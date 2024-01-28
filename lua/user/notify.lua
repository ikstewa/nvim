local M = {
  "rcarriga/nvim-notify",
}

function M.config()
  local notify = require("notify")

  vim.notify = notify
  notify.setup({
    stages = "fade_in_slide_out"
  })
end

return M
