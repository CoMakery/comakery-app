$ ->
  $('#send_link').change ->
    if $(this).is(':checked')
      $('.select-user').css('visibility', 'hidden')
    else
      $('.select-user').css('visibility', 'visible')
