local M = {}

local wrapQuotes = function(str)
  return "\"" .. str .. "\""
end

local echo = function(msg)
  msg = string.gsub(msg, "\n$", "")
  vim.api.nvim_echo({{msg, "Normal"}}, true, {})
end

function M.e1rm(set)
  local result = vim.fn.system("gym calc e1rm " .. wrapQuotes(set)) 

  -- If the command fails, return an empty list
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_err_writeln("Invalid set")
    return
  end

  echo(result);
end

function M.current_e1rm()
  local current = vim.api.nvim_get_current_line()
  M.e1rm(current)
end

function M.convert(fromSet, toSet)
  local args = wrapQuotes(fromSet) .. " " .. wrapQuotes(toSet)
  local result = vim.fn.system("gym calc convert " .. args)

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_err_writeln("Invalid set")
    return
  end

  echo(result);
end

function M.convert_current(toSet)
  local current = vim.api.nvim_get_current_line()
  M.convert(current, toSet)
end

return M
