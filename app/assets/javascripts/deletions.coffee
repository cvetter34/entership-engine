$ ->
  confirmationForm = (name) -> """
    <p>
      Please enter <strong>"#{name}"</strong> to confirm deletion.<br>
      <strong class="delete-warning">Remember that deletions are permanent.</strong>
    </p>
    <form id="confirmation-form" data-name="#{name}">
      <input class="form-control" type="text" id="confirm-text"
        name="confirm-text" placeholder="Enter '#{name}' here to delete">
    </form>
  """

  $('body').on 'submit', '#confirmation-form', (e) ->
    e.preventDefault()
    $('.confirmed-deletion-button').click()

  $('body').on 'click', '[data-url]', (e) ->
    url = $(@).data('url')
    name = $(@).data('name')
    redirect = $(@).data('redirect')
    notify = ->
      noty
        layout: "bottomRight"
        type: "warning"
        timeout: 4000,
        text: "#{name} was not deleted."
    bootbox.dialog {
      message: confirmationForm(name)
      title: "Are you sure you want to delete #{name}?"
      onEscape: notify
      buttons:
        cancel:
          label: "DO NOT DELETE!"
          className: "btn-primary"
          callback: notify
        success:
          label: "Delete #{name}"
          className: "btn-danger confirmed-deletion-button"
          callback: (x) ->
            if name == $('#confirm-text').val()
              console.log "url", url
              $.ajax( url, method: "DELETE" ).done ->
                window.location.href = redirect
            else
              notify()
      value: ""
      inputType: "password"
      placeholder: "Enter your password"
    }
