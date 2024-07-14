local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local utils = require("utils")

local M = {}

local get_exercise_prs = function(name, exact)
  local flags = exact and "-ej" or "-j"
  -- Run the command in the same directory as the current file
  local result = vim.fn.system(utils.wrapChDir("gym exercise prs " .. flags .. " \"" .. name .. "\""))

  if vim.v.shell_error ~= 0 then
    return {}
  end

  local ok, response = pcall(vim.fn.json_decode, result)

  if not ok then
    return {}
  end

  return response
end

local format_pr = function(pr)
  local unit = pr.weightUnit or "kg"
  local rm = pr.reps .. "RM: " .. pr.weight .. unit
  local instance = pr.reps == pr.actualReps and "" or pr.weight .. "x" .. pr.actualReps .. " on "
  return rm .. " (" .. instance .. pr.date .. ")"
end


M.picker = function(opts)
  opts = opts or {}
  local name = utils.get_current_exercise_name()
  -- Show error message if nil
  if name == nil then
    vim.api.nvim_err_writeln("Cursor is not in an exercise")
    return
  end

  local results = get_exercise_prs(name, opts.exact)

  if #results == 0 then
    vim.api.nvim_err_writeln("No PRs found for " .. name)
    return
  end

  pickers.new(opts, {
    prompt_title = name .." PRs",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return {
          value = entry.reps,
          display = format_pr(entry),
          ordinal = entry.reps,
          filename = entry.fileName,
          path = entry.filePath,
          lnum =  entry.lineStart
        }
      end
    },
    previewer = utils.gym_file_previewer,
    sorter = conf.generic_sorter(opts),
  }):find()
end

return M
