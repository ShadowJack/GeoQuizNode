$ ->
  $('#next').click (event) ->
    console.log('"Next" button clicked!')
    #handle the click on the 'Next' button
    #send the get request to node that will prepare and update data in #photo
    $.get '/next_image', (pic_url) ->
      $('#photo').attr('src', pic_url)
