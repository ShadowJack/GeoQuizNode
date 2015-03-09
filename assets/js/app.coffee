$ ->
  #----------------------------------------------------
  # Global vars:
  
  photos = []
  countries = []
  score = 0
  prev_country = ''
  curr_photo = {}
  reqs_count = 0
  change_score_count = 0
  active_thumb = 0
  timer = null
  full_width = 0
  APP_ID = '4442537'
  app_id = ''
  uid = ''


#----------------------------------------------------
# Utils, routines...
#
  
  #`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`
  # Time left  
  
  resumeTimer = ->
    timer = setInterval(update_bar, 1000)
  
  cleanTimer = ->
    console.log 'get in Stop timer()'
    if timer != null
      console.log 'timer was not null'
      clearInterval(timer)
      timer = null
      
  
  resetTimer = ->
    #reset the timer of back-count
    cleanTimer()
    $('#timebar').css 'width', full_width
    resumeTimer()
    
  
  update_bar = ->
    if $('#timebar').width() > ( full_width / 20 )
      $('#timebar').css 'width', $('#timebar').width() - ( full_width / 20 )
    else
      # show the right answere
      cleanTimer()
      $('#timebar').css 'width', full_width
      change_score -5
      show_right_answere(3000)

  #`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`
  # Spalsh screen when need to pause  
  pauseScreen = ->
    cleanTimer() 
    $('#circular').show()
    $('#splash_screen').css 'visibility', 'visible'
    
  removePauseScreen = ->
    resumeTimer()  
    $('#circular').hide()
    $('#splash_screen').css 'visibility', 'hidden'
  
  #`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`
  # UI control  
  show_right_answere = (how_long) ->
    #show the right answere
    if curr_photo.country
      $('.btn-choose:contains("' + curr_photo.country + '")').css 'background-color', '#639c79'
      disable_buttons true
      window.setTimeout ->
        disable_buttons false
        $('.btn-choose:contains("' + curr_photo.country + '")').css 'background-color', '#E6E6E6'
        next_photo()
      , how_long
    else
      next_photo()


  disable_buttons = (disable) ->
      $('#skip').prop('disabled', disable)
      $('.btn-choose').prop('disabled', disable)
  
  #`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`
  # Score manipulations
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

    field = (if val > 0 then $('#up_score') else $('#down_score'))
    field.html (if val > 0 then '+' + val else val)
    field.fadeIn 200, ->
      curr_top = parseInt(field.css('top').match /\d+/)
      field.animate {
        top: (curr_top - val*2) + 'px',
        opacity: 0.0
      }, 600, ->
        field.css 'top', curr_top
        field.css 'opacity', 1.0
        field.css 'display', 'none'
    
    $('#score').fadeOut 300, ->
      $('#score').html score
      $('#score').fadeIn 300
  
  #`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`-`
  # The most complicated logic - get new set of photos and display new photo
  get_new_photos = ->
    page = Math.floor(Math.random()*266)
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
      
  
  next_photo = ()->
    if photos.length == 0
      get_new_photos()
      return
      
    $('#photo').hide()
    $('#circular').show()
    
    i = Math.floor(Math.random()*photos.length)
    #get the url_z of a random photo
    curr_photo = photos[i]
    
    #if we picked the photo with te same country as previous - try again
    #only if we have all photos with the same country then we have no options
    
    if (prev_country and prev_country == curr_photo.country)
      next_photo()
    else    
      #remove new photo from the array of remaining photos
      photos.splice i, 1
      #console.log 'Removed one photo, new length: ' + photos.length
      if photos.length < 8
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
        top = (400 - $('#photo').height()) / 2
        $('#photo').css('top', top)
        resetTimer()
        
      if active_thumb == 1
        $('#thumbs_up').css 'background', 'url(/img/thumbs_up20.png)'
        active_thumb = 0
      if active_thumb == -1
        $('#thumbs_down').css 'background', 'url(/img/thumbs_down20.png)'
        active_thumb = 0

#-------------------------------------------------
# Callbacks on the most of ui events
  
  # Post current photo to user's wall
  #
  onVkShare = (event) ->
    resource = $('#photo').attr 'src'
    #if there is no photo then return without any actions
    if resource == ''
      console.log "Can't get the photo res"
      return false
    
    # add score to the photo even if posting is unsuccessful
    thumb(true)
    
    pauseScreen()
    
    # 1. Get the server url where to upload photo
    VK.api 'photos.getWallUploadServer', {}, (response) ->
      if response.error
        console.log "Can't get WallUploadServer: " + JSON.stringify response.error
      else
        # 2. Send a POST request to url, that was recieved
        console.log 'I will POST photo to the ' + JSON.stringify response.response.upload_url
        $.post '/send_photo_to_vk',  {url: response.response.upload_url, photo: resource}, (upload_result) ->
          console.log 'Photo successfully uploaded: ' 
          console.log upload_result
          if upload_result.photo == "[]"
            return false
          else
            save_object =
              #user_id: parseInt(uid),
              photo: upload_result.photo,
              server: upload_result.server,
              hash: upload_result.hash
            
            # 3. Save uploaded photo to the wall
            console.log "Will save on wall: ", save_object
            VK.api 'photos.saveWallPhoto', save_object, (uploaded_photo) ->
              console.log "Saved photo to wall"
              att = 'photo' + uploaded_photo.response[0].owner_id + '_' + uploaded_photo.response[0].id + ',' + curr_photo.res_url
              console.log "Attachment: " + att
              # 4. Create a post with the photo uploaded earlier
              VK.api 'wall.post', {attachments: att}, (final_result) ->
                console.log 'Successfully posted on the wall: ', final_result
                removePauseScreen()
  
  
  
  # Save current photo to user's album
  #
  onVkSavePhoto = (event) ->
    resource = $('#photo').attr 'src'
    #if there is no photo then return without any actions
    if resource == ''
      console.log "Can't get the photo res"
      return false
      
    pauseScreen()
    
    # add score to the photo even if posting is unsuccessful
    thumb(true)
    
    VK.api 'storage.get', {key: 'albumId'}, (data) ->
      if data.error
        console.log "storage.get(albumId) error: ", data.error
        removePauseScreen()
        return false
      if data.response == ''
        console.log 'No album - try to create one'
        createAlbumAndSavePhoto()
      else
        # check if album we'd created at the first posting is still available
        VK.api 'photos.getAlbums', {album_ids: parseInt(data.response)}, (data) ->
          if data.error
            console.log "Error while getting albums: ", data.error
            removePauseScreen()
            return false
          if data.response.count == 0
            console.log 'Album not found: ', data.response
            createAlbumAndSavePhoto()
          else
            console.log data.response
            savePhoto(data.response.items[0].id)
  
  createAlbumAndSavePhoto = ->
    album_options = {
      title: 'Фото из приложения "Страновед"',
      description: 'Фотографии из приложения "Страновед" (vk.com/app' + app_id + ')',
      comment_privacy: 2 # друзья и друзья друзей
      privacy: 0
    }
    VK.api 'photos.createAlbum', album_options, (data) ->
      if data.error
        console.log data.error
        removePauseScreen()
        return false
      id = data.response.id
      VK.api 'storage.set', {key: 'albumId', value: id}, (data) ->
        if data.error
          console.log data.error
          removePauseScreen()
          return false
      savePhoto(id)
  
  savePhoto = (alb_id) ->
    resource = $('#photo').attr 'src'
    if resource == "Can't find the resource of photo"
      console.log ''
      removePauseScreen()
      return false
      
    VK.api 'photos.getUploadServer', {album_id: alb_id }, (data) ->
      if data.error
        console.log data.error
        removePauseScreen()
        return false
      $.post '/send_photo_to_vk',  {url: data.response.upload_url, photo: resource}, (upload_result) ->
        console.log 'Photo successfully uploaded: ' 
        console.log upload_result
        if upload_result.photo == "[]"
          removePauseScreen()
          return false
        else
          VK.api 'photos.save', {
            album_id: upload_result.aid,
            server: upload_result.server,
            photos_list: upload_result.photos_list,
            hash: upload_result.hash,
            caption: 'Оригинал: ' + curr_photo.res_url + '\nФото из приложения: vk.com/app' + app_id
          }, (final_result) ->
            console.log 'Successfully posted to the album: ', final_result
            removePauseScreen()
            
  # The guess has been made
  #
  onChoose = (event) ->
    cleanTimer()
    if this.innerHTML == curr_photo.country
      change_score 20
      next_photo()
    else
      change_score -10
      show_right_answere(1000)
  
  # Skip to the next photo
  #
  onSkip = (event) ->
    cleanTimer()
    if photos.length == 0
      $('#skip').prop('disabled', true)
      get_new_photos()
      return false
    change_score -5
    show_right_answere(1000)
    return true
    
  # Thumbs up or down pressed
  #
  onThumbs = (event) ->
    event.preventDefault()
    up = ($(this).attr('id') == 'thumbs_up')
    #do nothing if we clicked on the active button
    if (up && active_thumb == 1) or (!up && active_thumb == -1)
      return false
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
    
    thumb(up)
    return true
   
  # Util - posts thumb (up or down) to server -> db
  #  
  thumb = (up) ->
    console.log "Thumb up: ", up
    $.post '/thumbs', {up: up, photo: curr_photo}, (data, status, jqXHR)->
      if status != 'ok' and status != '200' and status != 'success'
        console.log 'Wrong status: ', status
        return false
      if data.error
        console.log "Error while changing photo score: " + JSON.parse data.error
        return false
    , 'json'
  
  
  
  # When load the app we init VK JSapi
  # this callback gets the score of current user and sets 
  # some useful variables to interact with vk
  #
  onVkInitSuccess = (data) -> 
    uid = document.location.search.match(/user_id=\d+/)[0].slice 8
    app_id = document.location.search.match(/api_id=\d+/)[0].slice 7
    
    
    VK.addCallback 'onWindowBlur', ->
      console.log 'Pause game'
      pauseScreen()
  
    VK.addCallback 'onWindowFocus', ->
      console.log 'Resume game'
      removePauseScreen()
    
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
    
    #TODO: get info about leaders and add them in leaderboard
    #$.post '/user_score', {uid: uid, score: score}
  # If the initialization of VK JSapi wasn't successful then reload page and try gain
  #
  onVkInitFail = ->
    window.top.location=window.top.location
  
  
  

#-->-->-->-->-->-->-->-->-->-->-->--> 
#The begining of the execution
 
  full_width = $(window).width()
  console.log full_width
  
  disable_buttons(true)
  $('#photo').hide()
  
  $.getJSON '/countries.json', (data) ->
    countries = data["countries"]
    get_new_photos()
  
  VK.init onVkInitSuccess, onVkInitFail, '5.21'
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Add events listeners
  $('#vk_share').on 'click', onVkShare
  
  $('#vk_save_photo').on 'click', onVkSavePhoto
  
  $('.btn-choose').on 'click', onChoose
  
  $('#skip').on 'click', onSkip
    
  $('#thumbs_up, #thumbs_down').on 'click', onThumbs
      
        
    
    
