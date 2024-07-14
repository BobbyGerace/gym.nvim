local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local utils = require("utils")

local M = {}

local get_current_workout_name = function()
  local buffer_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input_data = table.concat(buffer_content, "\n")

  -- pass buffer content into stdin
  local result = vim.fn.system('gym workout parse', input_data)
  -- decode the JSON response inside a try/catch block
  local ok, response = pcall(vim.fn.json_decode, result)

  if not ok then
    return nil
  end

  return response.frontMatter and response.frontMatter.name
end

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

M.current_workout_type_history_picker = function(opts)
  opts = opts or {}

  local name = get_current_workout_name()
  if name == nil then
    vim.api.nvim_err_writeln("Not in a named workout")
    return
  end

  M.workout_history_picker(vim.tbl_extend("force", opts, { name = name }))
end

return M
