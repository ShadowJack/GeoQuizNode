$ ->
  photos = []
  countries = []
  score = 0
  curr_country = ''
  
  get_new_photos = ->
    page = Math.floor(Math.random()*400)
    console.log page
    $.get '/load_new_photos?page='+page, (resp) ->
      photos = photos.concat resp
      console.log 'New photos added, and photos.length = ' + photos.length
      disable_buttons(false)
      if $('#photo').attr('src') == ''
        next_photo()
      else if $('#photo').is(':hidden')
        $('#photo').show()
      
  
  next_photo = ->
    $('#photo').hide()
    $('#circular').show()
    
    i = Math.floor(Math.random()*photos.length)
    console.log 'i: ' + i
    #get the url_z of a random photo
    photo_url = photos[i].url
    curr_country = photos[i].country
    
    #remove new photo from the array of remaining photos
    photos.splice i, 1
    console.log 'Removed one photo from the photos array, new length: ' + photos.length
    if photos.length < 5
      get_new_photos()
  
    
    console.log "url: " + photo_url + " country: " + curr_country
    if not curr_country
      next_photo()
    else
      #get next countries to display on buttons
      next_countries = [curr_country]
      while next_countries.length < 4
        country_index = Math.floor Math.random()*countries.length
        if countries[country_index] != curr_country
          next_countries.push countries[country_index]
          
      #set the buttons to display new data
      for i in [1..4]
        rand_button = $("#btn" + i)
        c_index = Math.floor Math.random()*next_countries.length
        rand_button.html next_countries[c_index]
        next_countries.splice c_index, 1
         
      #load new photo to the img element
      $('#photo').attr('src', photo_url).on 'load', ->
        $('#circular').hide()
        $('#photo').show()
  
  disable_buttons = (enable) ->
      $('#skip').prop('disabled', enable)
      $('.btn-choose').prop('disabled', enable)

  #------------------------------  
  #The begining of the execution
  disable_buttons(true)
  $('#photo').hide()
  $.getJSON '/countries.json', (data) ->
    countries = data["countries"]
    get_new_photos()
  
  
  $('.btn-choose').click (event) ->
    if this.innerHTML == curr_country
      score += 30
    else
      score -= 10
    console.log 'score: ' + score
    next_photo()
  
  $('#skip').click (event) ->
    if photos.length == 0
      $('#skip').prop('disabled', true)
      get_new_photos()
      return false
    score -= 5
    console.log 'score: ' + score
    next_photo()
    return true
    
    
