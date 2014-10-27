$ ->
  showHelp = (e) ->
    $("##{$(@).attr('data-help-id')}").fadeIn()

  hideHelp = (e) ->
    $("##{$(@).attr('data-help-id')}").hide()

  $('form').on 'focus', '.has-help', showHelp
  $('form').on 'blur', '.has-help', hideHelp
