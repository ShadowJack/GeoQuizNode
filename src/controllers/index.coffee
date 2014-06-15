api_key = '5b05639ce9be5ae209e85779df2d66dd'
request = require('request')
photos = []
exports.index = (req, res) ->
    res.render 'index'
    
exports.next_image = (req, res) ->
  if photos.length < 100
    console.log 'ready to fetch next image'
    #fetch the next photo in the array of recent photos from Flickr
    #page = Math.ceil Math.random()*1000
    options =
      hostname: 'https://api.flickr.com',
      path: '/services/rest/?format=json&method=flickr.photos.getRecent&extras=geo,url_z&api_key='+api_key
    
    #console.log 'options: \n' + JSON.stringify options 
    #prepare the request to flickr.api  
    request options.hostname+options.path, (err, resp, body) ->
      data = JSON.parse(body.slice 14, -1)
      if err
        console.log 'Error: ' + err
        return
      #console.log data
      if (data.stat != "ok")
        return
      photos = photos.concat data.photos.photo
      console.log 'Just added photos to the Photos array. New length: ' + photos.length
      i = Math.floor(Math.random()*photos.length)
      #console.log photos[i]
      #get the url_z of a random photo
      photo_url = photos[i].url_z
      #remove showed photo from the array
      photos.splice i, 1
      console.log 'Removed one photo from the photos array, new length: ' + photos.length
      #send the response back to app.coffee, where jQuery asked for data
      res.send photo_url
  else
    console.log 'Photos array is hashed! ' + photos.length 
    i = Math.floor(Math.random()*500)
    #console.log photos
    #get the url_z of a random photo
    photo_url = photos[i].url_z
    #remove showed photo from the array
    photos.splice i, 1
    console.log photos.length
    #send the response back to app.coffee, where jQuery asked for data
    res.send photo_url  
    
    
    
