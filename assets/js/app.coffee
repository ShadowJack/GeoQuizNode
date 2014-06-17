$ ->
  photos = []
  page = 1
  
  get_new_photos = ->
    $.get '/load_new_photos?page='+page, (new_photos) ->
      page += 1
      photos = photos.concat new_photos
      console.log 'New photos added, and photos.length = ' + photos.length
      #console.log photos
  
  get_new_photos()
  
  $('#next').click (event) ->
    if photos.length == 0
      get_new_photos()
      #TODO: заменить на крутящееся колёсико, проверяющее состояние загрузки фото
      while photos.length <= 0
        1
    i = Math.floor(Math.random()*photos.length)
    console.log 'i: ' + i
    #get the url_z of a random photo
    photo_url = photos[i].url
    photo_country = photos[i].country
    #remove showed photo from the array
    photos.splice i, 1
    console.log 'Removed one photo from the photos array, new length: ' + photos.length
    if photos.length < 5
      get_new_photos()
    console.log "url: " + photo_url + "country: " + photo_country
    $('#photo').attr('src', photo_url)
    
    
    
