vim.cmd(
[[
function OpenMarkdownPreview (url)
  execute 'silent ! open -na "Brave Browser" --args --new-window ' . a:url
  " execute 'silent ! open -na "Google Chrome" --args --new-window ' . a:url
endfunction
]]
)

vim.g.mkdp_browserfunc = 'OpenMarkdownPreview'
