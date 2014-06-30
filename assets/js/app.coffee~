$ ->
  photos = []
  countries = []
  score = 0
  prev_country = ''
  curr_country = ''
  reqs_count = 0
  change_score_count = 0
  
  get_new_photos = ->
    page = Math.floor(Math.random()*200)
    #console.log page
    $.get '/load_new_photos?page='+page, (resp) ->
      if resp.length == 0
        if reqs_count < 3
          reqs_count += 1
          get_new_photos()
        else
          console.log 'Unable to retrieve new photos, sorry...'
      else
        reqs_count = 0
        photos = photos.concat resp
        console.log 'New photos added, and photos.length = ' + photos.length
        disable_buttons(false)
        if $('#photo').attr('src') == ''
          next_photo()
        else if $('#photo').is(':hidden')
          $('#photo').show()
      
  
  next_photo = ->
    
    #show the right answere
    if curr_country
      console.log 'change color'
      right_button = $('.btn-choose:contains("' + curr_country + '")')
      right_button.css 'background-color', '#639c79'
    
    $('#photo').hide()
    $('#circular').show()
    
    i = Math.floor(Math.random()*photos.length)
    #get the url_z of a random photo
    photo_url = photos[i].url
    curr_country = photos[i].country
    
    #if we picked the photo with te same country as previous - try again
    #only if we have all photos with the same country then we have no options
    
    #TODO: отлавливать случаи, когда все оставшиеся фотографии с одной страны
    if (prev_country and prev_country == curr_country)
      next_photo()
    else    
      #remove new photo from the array of remaining photos
      photos.splice i, 1
      #console.log 'Removed one photo, new length: ' + photos.length
      if photos.length < 5
        get_new_photos()
      
      #skip this photo if it has no country information
      #(shouldn't get here cause this conditions is checked before returning from /load_new_photos)
      if not curr_country
        console.log "Err: country property is 'undefined'!!!"
        next_photo()      
      
      #console.log "url: " + photo_url + " country: " + curr_country
      prev_country = curr_country
      #get possible countries to display on buttons
      possible_countries = [curr_country]
      possible_countries_indexes = []
      while possible_countries.length < 4
        country_index = Math.floor Math.random()*countries.length
        if countries[country_index] != curr_country and $.inArray(country_index, possible_countries_indexes) == -1
          possible_countries.push countries[country_index]
          possible_countries_indexes.push country_index
  
      if right_button
        right_button.css 'background-color', '#E6E6E6'
  
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
    if change_score_count % 3 == 0
      
      try
        VK.api 'storage.set', {key: 'score', value: score.toString()}, (resp) ->
          if resp.error or resp.response != 1
            console.log 'Error: Unable to update score! err: ' + resp.error
      catch e 
        console.log e
    
    change_score_count += 1
      
    $('#score').fadeOut 100, ->
      $('#score').html score
      $('#score').fadeIn 100


  #-->-->-->-->-->-->-->-->-->-->-->--> 
  #The begining of the execution
  disable_buttons(true)
  $('#photo').hide()
  $.getJSON '/countries.json', (data) ->
    countries = data["countries"]
    get_new_photos()
  
  VK.init (data) -> 
    VK.api 'storage.get', {key: 'score'}, (data) ->
      if data.response
        if data.response == ''
          #the first time in the app
          score = 0
          VK.api 'storage.set', {key: 'score', value: score.toString()}, (resp) ->
            if resp.error or resp.response != 1
              console.log 'Error: Unable to update score!'
        else
          score = parseInt data.response
        
        #set the score
        $('#score').html score
      else
        console.log 'Error: ' + JSON.stringify(data.error)
        window.top.location=window.top.location
  ,->
    window.top.location=window.top.location
  , 
  '5.21'
  
  $('.btn-choose').on 'click', (event) ->
    if this.innerHTML == curr_country
      change_score 20
    else
      change_score -10
    next_photo()
  
  $('#skip').on 'click', (event) ->
    if photos.length == 0
      $('#skip').prop('disabled', true)
      get_new_photos()
      return false
    change_score -5
    next_photo()
    return true
    
    
