mongoose = require 'mongoose'

# Picture model
Picture = new mongoose.Schema(
  someField: String
)

module.exports = mongoose.model 'Picture', Picture