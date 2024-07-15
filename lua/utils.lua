local previewers = require "telescope.previewers"

local M = {}

function M.wrapChDir(cmd)
  return "cd \"" .. vim.fn.expand("%:p:h") .. "\" && " .. cmd
end

function M.get_current_workout_name()
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


function M.get_current_exercise_name()
  local buffer_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input_data = table.concat(buffer_content, "\n")

  -- pass buffer content into stdin
  local result = vim.fn.system('gym workout parse', input_data)
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

M.gym_file_previewer = previewers.new_buffer_previewer({
  define_preview = function(self, entry, status)
    local bufnr = self.state.bufnr
    vim.api.nvim_buf_set_option(bufnr, 'filetype', 'gym')
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.fn.readfile(entry.path))
    
    if entry.lnum == nil then
      return
    end

    vim.fn.setpos('.', {bufnr, entry.lnum, 0, 0})
    vim.cmd('normal! zz')
    vim.api.nvim_buf_add_highlight(bufnr, -1, 'Search', entry.lnum - 1, 0, -1)
  end,
})

return M

