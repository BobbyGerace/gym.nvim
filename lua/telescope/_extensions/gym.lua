local exercise_history = require "telescope._extensions.pickers.exercise_history"
local exercises= require "telescope._extensions.pickers.exercises"

return require("telescope").register_extension {
  exports = {
    exercise_history = exercise_history.picker,
    exercises = exercises.picker,
  },
} 

