local exercise_history = require "telescope._extensions.pickers.exercise_history"
local exercises= require "telescope._extensions.pickers.exercises"
local workout_history = require "telescope._extensions.pickers.workout_history"
local prs = require "telescope._extensions.pickers.prs"

return require("telescope").register_extension {
  exports = {
    exercise_history = exercise_history.picker,
    exercises = exercises.picker,
    workout_history = workout_history.workout_history_picker,
    current_workout_type_history = workout_history.current_workout_type_history_picker,
    prs = prs.picker,
  },
} 

