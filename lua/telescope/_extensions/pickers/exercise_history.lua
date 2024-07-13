local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local M = {}

local wrapChDir = function(cmd)
  return "cd \"" .. vim.fn.expand("%:p:h") .. "\" && " .. cmd
end

local get_current_exercise_name = function()
  -- run `gym workout parse <filename>` on the current file
  handle = io.popen(wrapChDir("gym workout parse " .. vim.fn.expand("%:p")))
  result = handle:read("*a")
  handle:close()

  -- decode the JSON response inside a try/catch block
  local ok, response = pcall(vim.fn.json_decode, result)

  if not ok then
    return nil
  end

  -- search through response.exercises to find where lineStart and lineEnd contain cursor position
  for _, exercise in ipairs(response.exercises) do
    if exercise.lineStart <= vim.fn.line(".") and exercise.lineEnd >= vim.fn.line(".") then
      return exercise.name
    end
  end

  return nil
end

local get_exercise_history = function(name)
  -- Run the command in the same directory as the current file
  return vim.fn.systemlist(wrapChDir("gym exercise history -lf \"" .. name .. "\""))
end


M.picker = function(opts)
  opts = opts or {}
  local name = get_current_exercise_name()
  -- Show error message if nil
  if name == nil then
    vim.api.nvim_err_writeln("Cursor is not in an exercise")
    return
  end

  pickers.new(opts, {
    prompt_title = name .." History",
    finder = finders.new_table {
      results = get_exercise_history(name),
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
    previewer = previewers.new_buffer_previewer({
      define_preview = function(self, entry, status)
        local bufnr = self.state.bufnr
        vim.api.nvim_buf_set_option(bufnr, 'filetype', 'gym')
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.fn.readfile(entry.path))
        vim.fn.setpos('.', {bufnr, entry.lnum, 0, 0})
        vim.cmd('normal! zz')
        vim.api.nvim_buf_add_highlight(bufnr, -1, 'Search', entry.lnum - 1, 0, -1)
      end,
    }),
    sorter = conf.file_sorter(opts),
  }):find()
end

return M
