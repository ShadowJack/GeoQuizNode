api_key = '5b05639ce9be5ae209e85779df2d66dd'
request = require('request')
exports.index = (req, res) ->
    res.render 'index'
    
exports.load_new_photos = (req, res) ->
  console.log 'Ready to fetch new photos...'
  #fetch the next photo in the array of recent photos from Flickr
  options =
    hostname: 'https://api.flickr.com',
    path: '/services/rest/?format=json&method=flickr.photos.getRecent&page='+req.query.page+'&extras=geo,url_z&api_key='+api_key
  
  #console.log 'options: \n' + JSON.stringify options 
  #prepare the request to flickr.api  
  request options.hostname+options.path, (err, resp, body) ->
    data = JSON.parse(body.slice 14, -1)
    if err
      console.log 'Error: ' + err
      return
    #console.log data
    if (data.stat != "ok")
      console.log data.stat
      return
    res.send data.photos.photo
    
#TODO: в браузере у пользователя хранить номер очередной страницы, с которой будем загружать фото
# и передавать его в запросе методу load_new_photos
