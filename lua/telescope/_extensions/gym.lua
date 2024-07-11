local exercise_history = require "telescope._extensions.pickers.exercise_history"

return require("telescope").register_extension {
  exports = {
    exercise_history = exercise_history.picker,
  },
} 

