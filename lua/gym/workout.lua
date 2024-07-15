local utils = require("utils")

local M = {}

local get_history = function(name)
  local command = name and "gym workout history -flN \"" .. name .. "\"" or "gym workout history -fl"
  -- Run the command in the same directory as the current file
  local result = vim.fn.systemlist(utils.wrapChDir(command))

  -- If the command fails, return an empty list
  if vim.v.shell_error ~= 0 then
    return {}
  end

  return result
end

local current_file_path = function()
  return vim.fn.expand("%:p")
end

local strip_file_extension = function(path)
  return path:gsub("%..*$", "")
end

function M.next(name)
  local history = get_history(name)
  local current = current_file_path()

  local next = nil
  for i = #history, 1, -1 do
    -- The . breaks the sort order for deduped workouts because . > - 
    -- so we strip it
    if strip_file_extension(history[i]) > strip_file_extension(current) then
      next = history[i]
      break
    end
  end

  if next == nil then
    vim.api.nvim_err_writeln("No next workout found")
    return
  end

  vim.cmd("e " .. next)
end

function M.prev(name)
  local history = get_history(name)
  local current = current_file_path()

  local prev = nil
  for i = 1, #history do
    -- The . breaks the sort order for deduped workouts because . > - 
    -- so we strip it
    if strip_file_extension(history[i]) < strip_file_extension(current) then
      prev = history[i]
      break
    end
  end

  if prev == nil then
    vim.api.nvim_err_writeln("No previous workout found")
    return
  end

  vim.cmd("e " .. prev)
end

function M.current_name_next()
  local name = utils.get_current_workout_name()
  if name == nil then
    vim.api.nvim_err_writeln("Not in a named workout")
    return
  end
  M.next(name)
end

function M.current_name_prev()
  local name = utils.get_current_workout_name()
  if name == nil then
    vim.api.nvim_err_writeln("Not in a named workout")
    return
  end
  M.prev(name)
end

return M
