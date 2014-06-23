flickr_api_key = '5b05639ce9be5ae209e85779df2d66dd'
geonames_username = 'shadowjack'
request = require('request')

exports.index = (req, res) ->
    res.render 'index'
    
exports.load_new_photos = (req, res) ->
  console.log 'Ready to fetch new photos...'
  #fetch the next photo in the array of recent photos from Flickr
  req_url = 'https://api.flickr.com/services/rest?\
  format=json&method=flickr.photos.search&tags=landmark\
  &content_type=1&has_geo=1&per_page=20&page='+req.query.page+'&extras=geo,url_z&api_key='+flickr_api_key
  console.log req_url
  #prepare the request to flickr.api  
  request.get req_url, (err, resp, body) ->
    if err
      console.log 'Error: ' + err
      return
    #console.log body
#    if (body.stat != "ok")
#      console.log body.stat
#      return
    photos = JSON.parse(String(body).slice 14, -1).photos.photo
    result = []
    console.log 'I have got the photos'
    place_ids = []
    for photo in photos
      place_id = photo.place_id
      console.log place_id
      
      if place_ids.indexOf(place_id) != -1
        console.log 'place_id is dublicated'
        continue
      else
        place_ids.push place_id
      #get the country by lat, lon
      req_uri = 'http://api.geonames.org/countrySubdivisionJSON?username='+geonames_username+'&lat='+photo.latitude+'&lng='+photo.longitude+'&lang=ru&\
      uri=' + photo.url_z
      
      try
        request.get req_uri, (error, rsp, data) ->
          if error
            console.log 'Error: ' + err
            return
            
          console.log 'I recieved response from geonames:'
          img_url = (rsp.client._httpMessage.path.match /uri\=.+/)[0].slice 4
          
          geo_photo =
            url: img_url,
            country: JSON.parse(data).countryName
          console.log geo_photo
          result.push geo_photo
          
          #console.log "[result]: " + result.length + " [photos]: " + photos.length + " photo.url=" + photo.url_z
          
          # if we have recieved the last place info - send result to the client
          if result.length == place_ids.length
            console.log "Last geo info recieved: " + result.length
            res.send result
      catch e
        console.log e
      
    console.log "I've sent all geo requests and now waiting for responses"

#TODO: test, refactor

