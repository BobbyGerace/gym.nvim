local calc = require('gym.calc')
local workout = require('gym.workout')

M = {}

function M.setup(opts)
  -- Options are unused for now
  opts = opts or {}

  vim.api.nvim_create_user_command(
    'GymE1RM',
    function(opts)
      calc.e1rm(opts.fargs[1])
    end,
    { nargs = 1 }
  )

  vim.api.nvim_create_user_command(
    'GymCurrentE1RM',
    function()
      calc.current_e1rm()
    end,
    {}
  )

  vim.api.nvim_create_user_command(
    'GymConvert',
    function(opts)
      if #opts.fargs ~= 2 then
        vim.api.nvim_err_writeln("GymConvert requires exactly 2 arguments")
        return
      end
      local fromSet, toSet = opts.fargs[1], opts.fargs[2]
      calc.convert(fromSet, toSet)
    end,
    { nargs = '*' }
  )

  vim.api.nvim_create_user_command(
    'GymConvertCurrent',
    function(opts)
      calc.convert_current(opts.args)
    end,
    { nargs = 1 }
  )

  -- Workout commands
  vim.api.nvim_create_user_command(
    'GymWorkoutNext',
    function(opts)
      workout.next(opts.fargs[1])
    end,
    { nargs = '?' }
  )

  vim.api.nvim_create_user_command(
    'GymWorkoutPrev',
    function(opts)
      workout.prev(opts.fargs[1])
    end,
    { nargs = '?' }
  )

  vim.api.nvim_create_user_command(
    'GymWorkoutCurrentNameNext',
    function()
      workout.current_name_next()
    end,
    {}
  )

  vim.api.nvim_create_user_command(
    'GymWorkoutCurrentNamePrev',
    function()
      workout.current_name_prev()
    end,
    {}
  )
end

return M
