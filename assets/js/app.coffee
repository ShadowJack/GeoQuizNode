$ ->
  photos = []
  countries = []
  score = 0
  prev_country = ''
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
    #get the url_z of a random photo
    photo_url = photos[i].url
    curr_country = photos[i].country
    
    #remove new photo from the array of remaining photos
    photos.splice i, 1
    console.log 'Removed one photo, new length: ' + photos.length
    if photos.length < 5
      get_new_photos()

    console.log "url: " + photo_url + " country: " + curr_country
    #skip this photo if it has no country information
    # or the previous photo was from the same country 
    if not curr_country or (prev_country and prev_country == curr_country)
      next_photo()
    else
      prev_country = curr_country
      #get possible countries to display on buttons
      possible_countries = [curr_country]
      possible_countries_indexes = []
      while possible_countries.length < 4
        country_index = Math.floor Math.random()*countries.length
        if countries[country_index] != curr_country and $.inArray(country_index, possible_countries_indexes) == -1
          possible_countries.push countries[country_index]
          possible_countries_indexes.push country_index
          
      #set the buttons to display new data
      for i in [1..4]
        rand_button = $("#btn" + i)
        c_index = Math.floor Math.random()*possible_countries.length
        rand_button.html possible_countries[c_index]
        possible_countries.splice c_index, 1
         
      #load new photo to the img element
      $('#photo').attr('src', photo_url).on 'load', ->
        $('#circular').hide()
        $('#photo').show()
  
  disable_buttons = (enable) ->
      $('#skip').prop('disabled', enable)
      $('.btn-choose').prop('disabled', enable)
  
  change_score = (val) ->
    if score + val > 0 then score += val else score = 0
    $('#score').html score

  #-->-->-->-->-->-->-->-->-->-->-->--> 
  #The begining of the execution
  disable_buttons(true)
  $('#photo').hide()
  $.getJSON '/countries.json', (data) ->
    countries = data["countries"]
    get_new_photos()
  #TODO: загружать score
  $('#score').html score
  
  $('.btn-choose').click (event) ->
    if this.innerHTML == curr_country
      change_score 20
    else
      change_score -10
    next_photo()
  
  $('#skip').click (event) ->
    if photos.length == 0
      $('#skip').prop('disabled', true)
      get_new_photos()
      return false
    change_score -5
    next_photo()
    return true
    
    
