local M = {}

function M.wrapChDir(cmd)
  return "cd \"" .. vim.fn.expand("%:p:h") .. "\" && " .. cmd
end

return M

