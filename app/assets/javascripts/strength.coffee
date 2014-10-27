$ ->
  MIN_STRENGTH = 3

  if $('#*_email').val() == '' or $('#*_email').length < 1
    $('#*_email').focus()
  else
    $('#*_password').focus()

  $('#show-password-button').on 'click', (e) ->
    switch $(this).data('state')
      when 'show'
        $(this).html $(this).html().replace('Show','Hide')
        $(this).removeClass('btn-warning').addClass('btn-success')
        $('.showable-password').attr('type','text')
        $(this).data('state','hide')
      else
        $(this).html $(this).html().replace('Hide','Show')
        $(this).removeClass('btn-success').addClass('btn-warning')
        $('.showable-password').attr('type','password')
        $(this).data('state','show')

    $('.showable-password').first().focus()

    e.preventDefault()

  setStrengthMeter = (result) ->
    score = result.score
    strength = (score / 4) * 100

    color = switch score
      when 1 then 'danger'
      when 2 then 'warning'
      when 3 then 'success'
      else 'info'

    $('#time-to-crack').html result.crack_time_display

    $('#strength-meter')
      .removeClass('progress-bar-danger')
      .removeClass('progress-bar-warning')
      .removeClass('progress-bar-success')
      .removeClass('progress-bar-info')
      .addClass('progress-bar-' + color)
      .css('width', strength + '%')

    $('#strength-meter').attr 'aria-valuenow', strength
    $('#pct-strength').html "#{strength}% strength"

  allRequiredFields = () ->
    $('[required=required]').filter((x,y) -> $(y).val() == "").length == 0

  checkPasswordStrength = (score) ->
    if score >= MIN_STRENGTH
      $('#pw-quality').addClass 'ok'
      $('#pw-quality').html 'Password strength OK!'
      true
    else
      $('#pw-quality').removeClass 'ok'
      $('#pw-quality').html 'Password too weak!'
      false

  checkMatch = (score, pw, pc) ->
    if pw == pc
      $('#match-div').html("Passwords match!").addClass('pmatch')
      true
    else
      $('#match-div').html("Passwords don't match!").removeClass('pmatch')
      false

  passwordsOK = () ->
    if $('#*_password_confirmation')
      pw = $('#*_password').val()
      pc = $('#*_password_confirmation').val()

      [result, score] = try
        r = zxcvbn(pw)
        [r, r.score]
      catch
        [null, 0]

      setStrengthMeter(result) if result

      checkPasswordStrength(score) and checkMatch(score, pw, pc)
    else
      true

  enableSubmitButton = (enable) ->
    if enable
      $('.metered').removeAttr 'disabled'
    else
      $('.metered').attr 'disabled', 'disabled'

  validateForm = (event) ->
    enableSubmitButton( passwordsOK() and allRequiredFields() )

  $('body').on 'keyup', '[required=required]', validateForm
