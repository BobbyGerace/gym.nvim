local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local utils = require("utils")

local M = {}

local get_workout_history = function(name)
  local command = name and "gym workout history -flN \"" .. name .. "\"" or "gym workout history -fl"
  -- Run the command in the same directory as the current file
  local result = vim.fn.systemlist(utils.wrapChDir(command))

  -- If the command fails, return an empty list
  if vim.v.shell_error ~= 0 then
    return {}
  end

  return result
end


M.workout_history_picker = function(opts)
  opts = opts or {}

  local name = opts.name
  local results = get_workout_history(name)

  if #results == 0 then
    vim.api.nvim_err_writeln("No history found")
    return
  end

  local title = name and name .. " Workout History" or "Workout History"

  pickers.new(opts, {
    prompt_title = title,
    finder = finders.new_table {
      results = results,
      entry_maker = function(filepath)
        local filename = vim.fn.fnamemodify(filepath, ":t")
        return {
          value = filename,
          display = filename,
          ordinal = filename,
          filename = filename,
          path = filepath,
        }
      end
    },
    previewer = utils.gym_file_previewer,
    sorter = conf.file_sorter(opts),
  }):find()
end

M.current_workout_name_history_picker = function(opts)
  opts = opts or {}

  local name = utils.get_current_workout_name()
  if name == nil then
    vim.api.nvim_err_writeln("Not in a named workout")
    return
  end

  M.workout_history_picker(vim.tbl_extend("force", opts, { name = name }))
end

return M
