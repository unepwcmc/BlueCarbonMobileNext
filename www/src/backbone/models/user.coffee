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
      url: 'http://mozambique.blueforests.dev/my/users/sign_in.json'
      data: { user: { email: form.email, password: form.password } }
      dataType: 'json'
      success: (data) =>
        @set('auth_token', data.auth_token)
        BlueCarbon.bus.trigger('user:gotAuthToken', data.auth_token)

        @get_profile(@save_profile_with(success), error)
      error: error
    )

  save_profile_with: (success) =>
    (data) =>
      @set('email', data.email)
      @set('bounds', JSON.stringify(data.country.bounds))

      BlueCarbon.bus.trigger('user:loggedIn', @)
      @localSave({}, success: success)

  bounds: => JSON.parse(@get('bounds'))

  logout: (options) ->
    @localDestroy(
      success: ->
        BlueCarbon.bus.trigger('user:gotAuthToken', '')
        options.success()
    )
