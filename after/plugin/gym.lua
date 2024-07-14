local cmp = require('cmp')
local wrapChDir = require("utils").wrapChDir

if not cmp then
  return
end

local source = {}

local cached_exercises = nil
local get_exercises = function()
  if cached_exercises then
    return cached_exercises
  end

  local exercises = vim.fn.systemlist(wrapChDir("gym exercise list"))
  if vim.v.shell_error ~= 0 then
    return {}
  end

  cached_exercises = exercises
  return exercises
end

source.new = function()
  return setmetatable({}, { __index = source })
end


source.complete = function(self, request, callback)
  local exercises = get_exercises()

  local items = {}
  for _, exercise in ipairs(exercises) do
    table.insert(items, { label = exercise })
  end
  callback({ items = items, isIncomplete = false })
end

cmp.register_source('gym_exercises', source.new())

vim.api.nvim_create_autocmd("CursorMovedI", {
  callback = function()
    local col = vim.fn.col('.') - 1
    local synID = vim.fn.synID(vim.fn.line('.'), col, 1)
    local synName = vim.fn.synIDattr(synID, 'name')
    if synName == 'gymExName' then
      cmp.setup.buffer({
        sources = cmp.config.sources({
          { name = 'gym_exercises' },
        })
      })
    end
  end
})

