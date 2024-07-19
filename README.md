# gym.nvim

A neovim plugin for logging workouts with [gym](https://github.com/BobbyGerace/gym).

![gym.nvim](https://github.com/user-attachments/assets/a7a0af7f-d9c1-4f2c-bdcd-eeeeedf9a627)

Includes:

- Syntax highlighting
- Telescope pickers for exercises, workout history, and PRs
- CMP completion for exercises
- Commands for calculating 1RM, RPE, and more

## Installation

[gym](https://github.com/BobbyGerace/gym) must be installed as a dependency.

With Packer:

```lua
use {
  'BobbyGerace/gym.nvim',
  requires = {'BobbyGerace/gym'},
  config = function()
    require'gym'.setup()
  end
}
```

Telescope and CMP are optional dependencies. If you want to use them, you'll need to install them separately.

Telescope setup:

```lua
local telescope = require('telescope')
telescope.load_extension('gym')
```

## Usage

### Telescope Pickers

```lua
-- View history for exercise under cursor
telescope.extensions.gym.exercise_history()

-- View exercises (inserts exercise name into buffer)
telescope.extensions.gym.exercises()

-- View previous workouts
telescope.extensions.gym.workout_history()

-- View previous workouts of the same name
telescope.extensions.gym.current_workout_name_history()

--View PRs for exercise under the cursor
-- pass in { exact = true } to only match PRs with the exact number of reps. Be default it will show all PRs greater than or equal to the number of reps.
telescope.extensions.gym.prs()
```

### Commands

```vim
" Calculate 1RM for a given set. Uses same set syntax as in a gym file
:GymE1RM 225x5@8 " Outputs 270

" Calculates 1RM for the current line under the cursor
:GymCurrentE1RM

" Takes weight, reps, and set into account to convert from one set to another.
" Takes a toSet and a fromSet, and fills in the blank in the latter
:GymConvert 225x5@8 205@9 " Outputs x8

" Same as GymConvert, but uses the current line under the cursor for the fromSet
:GymConvertCurrent 205@9

" Goes to the next workout in the history
:GymWorkoutNext

" Goes to the previous workout in the history
:GymWorkoutPrevious

" Goes to the next workout of the same name in the history
:GymWorkoutCurrentNameNext

" Goes to the previous workout of the same name in the history
:GymWorkoutCurrentNamePrevious
```

The above commands are also available as lua functions:

```lua
local calc = require('gym.calc')
local workout = require('gym.workout')

calc.e1rm('225x5@8') -- 270
calc.current_e1rm() -- 270
calc.convert('225x5@8', '205@9') -- 'x8'
calc.convert_current('205@9') -- 'x8'
workout.workout_next()
workout.workout_previous()
workout.workout_current_name_next()
workout.workout_current_name_previous()
```
