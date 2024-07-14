local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local wrapChDir = require("utils").wrapChDir

local M = {}

local get_exercises = function()
  -- Run the command in the same directory as the current file
  local result = vim.fn.systemlist(wrapChDir("gym exercise list"))

  -- If the command fails, return an empty list
  if vim.v.shell_error ~= 0 then
    return {}
  end

  return result
end


M.picker = function(opts)
  opts = opts or {}
  -- Show error message if nil
  local results = get_exercises()
  
  -- join results into string
  local filename = table.concat(results, ",")

  if #results == 0 then
    vim.api.nvim_err_writeln("No exercises found")
    return
  end

  pickers.new(opts, {
    prompt_title = "Exercises",
    finder = finders.new_table {
      results = results,
      entry_maker = function(exercise)
        return {
          value = exercise,
          display = exercise,
          ordinal = exercise,
        }
      end
    },
    sorter = conf.generic_sorter(opts),
    -- Set the default action to put the exercise name in at the cursor lotaion
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.api.nvim_put({selection.value}, "", true, true)
      end)

      return true
    end,
  }):find()
end

return M
