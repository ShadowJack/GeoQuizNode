$ ->
  photos = []
  countries = []
  score = 0
  prev_country = ''
  curr_photo = {}
  reqs_count = 0
  change_score_count = 0
  active_thumb = 0
  
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
    
    $('#photo').hide()
    $('#circular').show()
    
    i = Math.floor(Math.random()*photos.length)
    #get the url_z of a random photo
    curr_photo = photos[i]
    
    #if we picked the photo with te same country as previous - try again
    #only if we have all photos with the same country then we have no options
    
    #TODO: отлавливать случаи, когда все оставшиеся фотографии с одной страны
    if (prev_country and prev_country == curr_photo.country)
      next_photo()
    else    
      #remove new photo from the array of remaining photos
      photos.splice i, 1
      #console.log 'Removed one photo, new length: ' + photos.length
      if photos.length < 5
        get_new_photos()
      
      #skip this photo if it has no country information
      #(shouldn't get here cause this conditions is checked before returning from /load_new_photos)
      if not curr_photo.country
        console.log "Err: country property is 'undefined'!!!"
        next_photo()      
      
      #console.log "url: " + photo_url + " country: " + curr_photo.country
      prev_country = curr_photo.country
      #get possible countries to display on buttons
      possible_countries = [curr_photo.country]
      possible_countries_indexes = []
      while possible_countries.length < 4
        country_index = Math.floor Math.random()*countries.length
        if countries[country_index] != curr_photo.country and $.inArray(country_index, possible_countries_indexes) == -1
          possible_countries.push countries[country_index]
          possible_countries_indexes.push country_index
  
      #set the buttons to display new data
      for i in [1..4]
        rand_button = $("#btn" + i)
        c_index = Math.floor Math.random()*possible_countries.length
        rand_button.html possible_countries[c_index]
        possible_countries.splice c_index, 1
    
           
      #load new photo to the img element
      $('#photo').attr('src', curr_photo.url).on 'load', ->
        $('#circular').hide()
        $('#photo').show()
        $('#photo_url').prop 'href', curr_photo.res_url
        #center the image
        top = (400 - $('#photo').height())/2
        $('#photo').css 'top', top
      
      if active_thumb == 1
        $('#thumbs_up').css 'background', 'url(/img/thumbs_up20.png)'
        active_thumb = 0
      if active_thumb == -1
        $('#thumbs_down').css 'background', 'url(/img/thumbs_down20.png)'
        active_thumb = 0
        
  show_right_answere = ->
    #show the right answere
    if curr_photo.country
      $('.btn-choose:contains("' + curr_photo.country + '")').css 'background-color', '#639c79'
      window.setTimeout ->
        $('.btn-choose:contains("' + curr_photo.country + '")').css 'background-color', '#E6E6E6'
        next_photo()
      , 1000
    else
      next_photo()


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
    #reload page
    window.top.location=window.top.location
  , 
  '5.21'
  
  $('.btn-choose').on 'click', (event) ->
    if this.innerHTML == curr_photo.country
      change_score 20
      next_photo()
    else
      change_score -10
      show_right_answere()
  
      
  $('#skip').on 'click', (event) ->
    if photos.length == 0
      $('#skip').prop('disabled', true)
      get_new_photos()
      return false
    change_score -5
    show_right_answere()
    return true
    
  $('#thumbs_up, #thumbs_down'). on 'click', (event) ->
    event.preventDefault()
    up = ($(this).attr('id') == 'thumbs_up')
    #do nothing if we clicked on the active button
    if (up && active_thumb == 1) or (!up && active_thumb == -1)
      return false
      
    $.post '/thumbs', {up: up, photo: curr_photo}, (data, status, jqXHR)->
      if status != 'ok' and status != '200'
        console.log status
        return
      if data.error
        console.log "Error while changing photo score: " + JSON.parse data.error
        return  
    , 'json'
    if up
      $(this).css 'background', "url(/img/thumbs_up_active20.png)"
      if active_thumb == -1
        $('#thumbs_down').css 'background', "url(/img/thumbs_down20.png)"      
      active_thumb = 1
      
    else
      $(this).css 'background', "url(/img/thumbs_down_active20.png)"
      if active_thumb == 1
        $('#thumbs_up').css 'background', "url(/img/thumbs_up20.png)"   
      active_thumb = -1
    return false
    
    
    
