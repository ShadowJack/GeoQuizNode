flickr_api_key = '5b05639ce9be5ae209e85779df2d66dd'
geonames_username = 'shadowjack'
DATABASE_URL = 'postgres://ubkjolguybaoep:xDt8jcTHKchp55eShePRoEwnir@ec2-54-197-241-97.compute-1.amazonaws.com:5432/d35pck0slu7rhd'
request = require('request')
pg = require('pg').native

exports.index = (req, res) ->
    res.render 'index'
    
exports.load_new_photos = (req, res) ->
  #res.setHeader { 'name': 'Content-Type', 'value': 'application/json' }
  console.log 'Ready to fetch new photos...'
  #fetch the next photo in the array of recent photos from Flickr
  req_url = 'https://api.flickr.com/services/rest?\
  format=json&method=flickr.photos.search&tags=landmark\
  &sort=relevance&content_type=1&has_geo=1&per_page=20&page='+req.query.page+'&extras=geo,url_z&api_key='+flickr_api_key
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
    place_ids = []
    counter = 0
    for photo in photos
      place_id = photo.place_id
     # console.log place_id
      
      if place_ids.indexOf(place_id) != -1
        #console.log 'place_id is dublicated'
        continue
      else
        place_ids.push place_id
      #get the country by lat, lon
      req_uri = 'http://api.geonames.org/countrySubdivisionJSON?username='+geonames_username+'&lat='+photo.latitude+'&lng='+photo.longitude+'&lang=ru&\
      uri=' + photo.url_z
      #console.log req_uri
      try
        request.get req_uri, (error, rsp, data) ->
          if error
            console.log 'Error: ' + err
            return
            
          #console.log 'I recieved response from geonames:'
          counter += 1
          img_url = (rsp.client._httpMessage.path.match /uri\=.+/)[0].slice 4
          
          geo_photo =
            url: img_url,
            country: JSON.parse(data).countryName
          console.log geo_photo
          if geo_photo.country != undefined
            result.push geo_photo
          
          #console.log "[result]: " + result.length + " [photos]: " + photos.length + " photo.url=" + photo.url_z
          
          # if we have recieved the last place info - send result to the client
          if counter == place_ids.length
            console.log "Last geo info recieved: " + result.length
            res.send result
            
            #save new photos to bd:
            pg.connect DATABASE_URL, (err, client, done) ->
              if err
                console.log err
                return

              for r in result
                query = client.query "INSERT INTO photos (url_z, country) VALUES ('" + r.url + "', '" + r.country + "');", (err, result)->
                  if err
                    console.log "Postgres db error: " + JSON.stringify err
              done()

      catch e
        console.log e
      
    console.log "I've sent all geo requests and now waiting for responses"

#TODO: кнопки оценки фотографии
#TODO: добавить таймаут, в котором проверять, если не все данные о фотографиях загрузились, то повторить загрузку
#TODO: убрать правый отступ во вконтакте - КААААААК???
#TODO: брать 15 фотографий с фликера, а оставшиеся 5 с базы данных



