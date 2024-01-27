
local status_ok, notify = pcall(require, "notify")
if not status_ok then
  return
end

vim.notify = notify

notify.setup({
    -- Animation style (see below for details)
  stages = "fade_in_slide_out",
})
