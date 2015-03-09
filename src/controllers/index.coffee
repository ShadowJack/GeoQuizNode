#TODO: прелоад следующей фотографии
#TODO: добавить рекламу
#TODO: подсказки при первом посещении приложения


flickr_api_key = '5b05639ce9be5ae209e85779df2d66dd'
geonames_username = 'shadowjack'
DATABASE_URL = process.env.DATABASE_URL
restler = require('restler')
request = require('request')
pg = require('pg')
fs = require('fs')
exec = require('child_process').exec
sys = require('sys')

exports.index = (req, res) ->
  res.render 'index'

exports.send_photo_to_vk = (req, res) ->
  # download photo from flickr to buffer
  server_url = req.body.url
  request.get {url: req.body.photo, encoding: null}, (err, resp, body) ->
    if err
      console.log 'Error: ' + err
      return
    if resp.statusCode != 200
      console.log 'Wrong response status: ' + resp.statusCode
      return
    
    restler.post(server_url, 
    {
      multipart: true,
      parser: restler.parsers.json,
      data: {
        'photo': restler.data('life_is_random.jpg', 'image/jpeg', body)
      }
    }).on('complete', (data, response) ->
        console.log 'Restler: ', data
        res.send data
      )

"""
post /user_score?uid=vk_uid

Updates user score into db.
If there is no such user in db - create it.
"""
exports.user_score = (req, res) ->
  pg.connect DATABASE_URL, (err, client, done) ->
    if err
      console.log err
      return done()

    query = client.query "SELECT * FROM users WHERE id=" + req.body.uid + ";", (err, reslt) ->
      if err
        console.log err
        return done()
      console.log "Get from db: ", result
      if result.length == 0
        # create new user
        client.query "INSERT INTO users VALUES (" + req.body.uid + ", " + req.body.score + ");", (err, reslt) ->
          if err
            console.log err
            return done()
          return
        
      
exports.load_new_photos = (req, res) ->
  #res.setHeader { 'name': 'Content-Type', 'value': 'application/json' }
  console.log 'Ready to fetch new photos...'
  #fetch the next photo in the array of recent photos from Flickr
  req_url = 'https://api.flickr.com/services/rest?\
  format=json&method=flickr.photos.search&tags=landmark\
  &sort=relevance&content_type=1&has_geo=1&per_page=15&page='+req.query.page+'&extras=geo,url_z&api_key='+flickr_api_key
  console.log req_url
  
  #prepare the request to flickr.api  
  request.get req_url, (err, resp, body) ->
    if err
      console.log 'Error: ' + err
      return
    photos = JSON.parse(String(body).slice 14, -1).photos.photo
    
    if photos.length == 0
      console.log 'No photos were recieved from Flickr'
      res.send []
      return
    
    result = []
    get_from_db = true
    get_from_flickr = false
    # pg.connect DATABASE_URL, (err, client, done) ->
    #   if err
    #     console.log err
    #     return done()
    #
#      query  = client.query "SELECT * FROM photos ORDER BY random() LIMIT 1;", (err, reslt) ->
#         if err
#           console.log err
#           get_from_db = true
#           return done()
#         console.log "Get from db: ", result
#         for r in reslt.rows
#           c_ph =
#             url: r.url_z,
#             country: r.country,
#             res_url: r.res_url
#
#           result.push (c_ph)
#         get_from_db = true
#         console.log "Got photos from db; flickr status: " + get_from_flickr
#         if get_from_flickr == true
#           res.send result
    
    
    place_ids = []
    counter = 0
    start_time = new Date().getTime()
    sent_requests_count = 0
    for photo in photos
      place_id = photo.place_id
      # console.log place_id
      
      if place_ids.indexOf(place_id) != -1
        #console.log 'place_id is dublicated'
        continue
      else
        place_ids.push place_id
      res_url = 'https://www.flickr.com/photos/' + photo.owner + '/' + photo.id
      #console.log "res_url in the request: " + res_url
      #get the country by lat, lon
      req_uri = 'http://api.geonames.org/countrySubdivisionJSON?username='+geonames_username+'&lat='+photo.latitude+'&lng='+photo.longitude+'&lang=ru&\
      uri=' + photo.url_z + '&res_url=' + res_url
      
      sent_requests_count += 1
      console.log sent_requests_count #'Geonames request: ' + req_uri
      try
        request.get req_uri, (error, rsp, data) ->
          if error
            console.log 'Error: ' + error
          else
            counter += 1
            console.log counter
            img_url = (rsp.client._httpMessage.path.match /uri\=.+&/)[0].slice 4, -1
            #console.log img_url
            res_url = (rsp.client._httpMessage.path.match /res_url\=.+/)[0].slice 8
            #console.log res_url
            geo_photo =
              url: img_url,
              country: JSON.parse(data).countryName,
              res_url: res_url,
            #console.log geo_photo
            if geo_photo.country != undefined
              result.push geo_photo
          
          #console.log "[result]: " + result.length + " [photos]: " + photos.length + " photo.url=" + photo.url_z
          
          # if we have recieved the last place info - send result to the client
          if (new Date(). getTime() - start_time) > 5000
            console.log 'waiting for too long... i will try again'
            get_from_flickr = true
            if get_from_db == true and not res.headerSent
              res.send result
              
          else if counter == place_ids.length
            get_from_flickr = true
            console.log "Photos from flickr are ready; db status: " + get_from_db
            if get_from_db == true and not res.headerSent
              res.send result
          
      catch e
        console.log e
        if not res.headerSent
          res.send result
      
    console.log "I've sent all geo requests and now waiting for responses"


exports.thumbs = (req, res) ->
  # try to get this photo from db
  pg.connect DATABASE_URL, (err, client, done) ->
    if err
      console.log err
      res.send {error: err}
      return done()
    
    query = client.query "SELECT * FROM photos WHERE url_z = '" + req.body.photo.url + "';", (err, result) ->
      if err
        console.log err
        res.send {error: err}
        return done()
        
      console.log req.body
      
      #this photo is not in the db
      if result.rowCount == 0 && req.body.up
        console.log "Try to add new photo to db"
        q = "INSERT INTO photos (url_z, country, score, res_url) VALUES ('" + req.body.photo.url + "', '" + req.body.photo.country + "', '1', '" + req.body.photo.res_url + "');"
        console.log q
        client.query q, (err, result)->
          if err
            console.log "Postgres db error: " + JSON.stringify err
          res.send result
        done()
      # this photo is in db  
      else if result.rowCount > 0 
        if (req.body.up == 'true')
          console.log "Try to increase the score of the photo"
          client.query "UPDATE photos SET score = score + 1 WHERE url_z = '" + req.body.photo.url + "';", (err, result)->
            if err
              console.log "Postgres db error: " + JSON.stringify err
            res.send result
          done()
        else
          console.log "Try to decrease the score of the photo"
          client.query "UPDATE photos SET score = score - 1 WHERE url_z = '" + req.body.photo.url + "';", (err, result)->
            if err
              console.log "Postgres db error: " + JSON.stringify err
            res.send result
          done()
      else    # photo not in db and we are trying to decrease score - do nothing
        res.send {}
