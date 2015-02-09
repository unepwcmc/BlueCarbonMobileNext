window.BlueCarbon ||= {}
window.BlueCarbon.Views ||= {}

ENTER_KEY = 13

class BlueCarbon.Views.LoginView extends Backbone.View
  template: JST['area/login']
  className: 'login'
  events:
    "click #login": "login"
    "keydown #password": "login"
    "keydown #username": "login"

  login: (event) =>
    return if event.type is "keydown" and  event.which isnt ENTER_KEY

    if navigator.connection.type == Connection.NONE
      alert("You are currently offline, please connect to the internet to login")
      return false

    $('#login-form .loading-spinner').show()

    @model.login(
      $('#login-form').serializeObject(),
      success: (data) =>
        @model.trigger('user:loggedIn', @model)

        $('#login-form .loading-spinner').hide()
        $('#login-form input').blur()
      error: (data) =>
        @showError('Unable to login')

        $('#login-form .loading-spinner').hide()
        $('#login-form input').blur()
    )

  render: ->
    @$el.html(@template())
    return @

  showError: (message)->
    $('.error').text(message)
    $('.error').slideDown()
