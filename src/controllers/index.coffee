#TODO: исправить работу ссылок на исходник изображения, разобраться почему не загружаются фотографии на сервер вконтакте
#TODO: добавить постинг на стену и в фотоальбом к пользователю
#TODO: добавить рекламу


flickr_api_key = '5b05639ce9be5ae209e85779df2d66dd'
geonames_username = 'shadowjack'
DATABASE_URL = process.env.DATABASE_URL
request = require('request')
pg = require('pg')
FormData = require('form-data')

exports.index = (req, res) ->
  res.render 'index'

exports.send_photo_to_vk = (req, res) ->
  # download photo from flickr to buffer
  form_data = new FormData()
  form_data.append 'photo', request(req.body.photo)
  form_data.submit req.body.url, (err, resp)->
    if err
      console.log  err
    res.send resp
    
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
    get_from_db = false
    get_from_flickr = false
    pg.connect DATABASE_URL, (err, client, done) ->
      if err
        console.log err
        return done()
      
      query = client.query "SELECT * FROM photos ORDER BY random() LIMIT 1;", (err, reslt) ->
        if err
          console.log err
          get_from_db = true
          return done()
        #console.log result
        for r in reslt.rows
          c_ph = 
            url: r.url_z,
            country: r.country,
            res_url: r.res_url
          
          result.push (c_ph)
        get_from_db = true
        if get_from_flickr == true
          res.send result
    
    
    place_ids = []
    counter = 0
    start_time = new Date().getTime()
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
      
      #console.log req_uri
      try
        request.get req_uri, (error, rsp, data) ->
          if error
            console.log 'Error: ' + err
            return
            
          #console.log 'I recieved response from geonames:'
          counter += 1
          img_url = (rsp.client._httpMessage.path.match /uri\=.+&/)[0].slice 4, -1
          #console.log img_url
          res_url = (rsp.client._httpMessage.path.match /res_url\=.+/)[0].slice 8, -1
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
            
          else if counter == place_ids.length
            console.log "Last geo info recieved: " + result.length
            get_from_flickr = true
            if get_from_db == true
              res.send result
          
      catch e
        console.log e
      
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
