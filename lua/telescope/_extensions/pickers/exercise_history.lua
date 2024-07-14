local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local utils = require("utils")

local M = {}

local get_exercise_history = function(name)
  -- Run the command in the same directory as the current file
  local result = vim.fn.systemlist(utils.wrapChDir("gym exercise history -lf \"" .. name .. "\""))

  -- If the command fails, return an empty list
  if vim.v.shell_error ~= 0 then
    return {}
  end

  return result
end


M.picker = function(opts)
  opts = opts or {}
  local name = utils.get_current_exercise_name()
  -- Show error message if nil
  if name == nil then
    vim.api.nvim_err_writeln("Cursor is not in an exercise")
    return
  end

  local results = get_exercise_history(name)

  if #results == 0 then
    vim.api.nvim_err_writeln("No history found for " .. name)
    return
  end

  pickers.new(opts, {
    prompt_title = name .." History",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        local filepath, lineno = string.match(entry, "(.*):(%d+)")
        -- Get the file name from the full path in a cross-platform way
        local filename = vim.fn.fnamemodify(filepath, ":t")
        return {
          value = filename,
          display = filename,
          ordinal = filename,
          filename = filename,
          path = filepath,
          lnum = tonumber(lineno),
        }
      end
    },
    previewer = utils.gym_file_previewer,
    sorter = conf.file_sorter(opts),
  }):find()
end

return M
