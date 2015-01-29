window.BlueCarbon ||= {}
window.BlueCarbon.Views ||= {}

class BlueCarbon.Views.LoginView extends Backbone.View
  template: JST['area/login']
  className: 'login'
  events:
    "click #login": "login"

  login: =>
    if navigator.connection.type == Connection.NONE
      alert("You are currently offline, please connect to the internet to login")
      return false

    $('#login-form .loading-spinner').show()

    @model.login(
      $('#login-form').serializeObject(),
      success: (data)=>
        $('#login-form .loading-spinner').hide()
        @model.trigger('user:loggedIn', @model)
        $(window).scrollTop(0)
      error: (data)=>
        $('#login-form .loading-spinner').hide()
        @showError('Unable to login')
        $(window).scrollTop(0)
    )

  render: ->
    @$el.html(@template())
    return @

  showError: (message)->
    $('.error').text(message)
    $('.error').slideDown()
