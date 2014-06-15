Picture = require '../models/picture'

# Picture model's CRUD controller.
module.exports = 

  # Lists all pictures
  index: (req, res) ->
    Picture.find {}, (err, pictures) ->
      res.send pictures
      
  # Creates new picture with data from `req.body`
  create: (req, res) ->
    picture = new Picture req.body
    picture.save (err, picture) ->
      if not err
        res.send picture
        res.statusCode = 201
      else
        res.send err
        res.statusCode = 500
        
  # Gets picture by id
  get: (req, res) ->
    Picture.findById req.params.id, (err, picture) ->
      if not err
        res.send picture
      else
        res.send err
        res.statusCode = 500
             
  # Updates picture with data from `req.body`
  update: (req, res) ->
    Picture.findByIdAndUpdate req.params.id, {"$set":req.body}, (err, picture) ->
      if not err
        res.send picture
      else
        res.send err
        res.statusCode = 500
    
  # Deletes picture by id
  delete: (req, res) ->
    Picture.findByIdAndRemove req.params.id, (err) ->
      if not err
        res.send {}
      else
        res.send err
        res.statusCode = 500
      
  