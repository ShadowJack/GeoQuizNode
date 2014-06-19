$ ->
  photos = []
  page = 0
  
  get_new_photos = ->
    page += 1
    $.get '/load_new_photos?page='+page, (new_photos) ->
      photos = photos.concat new_photos
      console.log 'New photos added, and photos.length = ' + photos.length
      $('#skip').prop('disabled', false)
      #
      if $('#photo').attr('src') == ''
        next_photo()
      else if $('#photo').is(':hidden')
        $('#photo').show(1)
      #console.log photos
      
  $('#skip').prop('disabled', true)
  $('#photo').hide()
  get_new_photos()
  
  next_photo = ->
    $('#photo').hide()
    $('#circular').show()
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
    $('#photo').attr('src', photo_url).on('load', ->
      $('#circular').hide()
      $('#photo').show()
    )
  
  $('#skip').click (event) ->
    if photos.length == 0
      $('#skip').prop('disabled', true)
      get_new_photos()
      return false
    next_photo()
    return true
    
    
