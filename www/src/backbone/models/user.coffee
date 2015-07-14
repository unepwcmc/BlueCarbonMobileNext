window.BlueCarbon ||= {}
window.BlueCarbon.Models ||= {}

class BlueCarbon.Models.User extends Backbone.SyncableModel
  schema: -> """
    sqlite_id INTEGER PRIMARY KEY,
    id INTEGER,
    auth_token TEXT,
    email TEXT,
    bounds TEXT
  """

  get_or_login: (form, options) ->
    @get_profile(options.success, (data) =>
      if data.error?
        @login(form, options.success, options.error)
      else
        options.error(data)
    )

  get_profile: (success, error) ->
    $.ajax(
      type: 'GET'
      url: 'http://bluecarbon.unep-wcmc.org/admins/me.json'
      success: success
      error: error
    )

  login: (form, success, error) =>
    $.ajax(
      type: 'POST'
      url: 'http://bluecarbon.unep-wcmc.org/my/admins/sign_in.json'
      data: { admin: { email: form.email password: form.password } }
      dataType: 'json'
      success: @handle_login_with(form, success)
      error: error
    )

  handle_login_with: (form, success) =>
    (data) =>
      @set('email', form.email)
      @set('auth_token', data.auth_token)

      @localSave({}, success: (a,b,c) =>
        success(@)
        BlueCarbon.bus.trigger('user:gotAuthToken', data.auth_token)
        BlueCarbon.bus.trigger('user:loggedIn', @)
      )


  logout: (options) ->
    @localDestroy(
      success: ->
        BlueCarbon.bus.trigger('user:gotAuthToken', '')
        options.success()
    )
