window.BlueCarbon ||= {}
window.BlueCarbon.Models ||= {}

class BlueCarbon.Models.User extends Backbone.SyncableModel
  schema: ->
    "sqlite_id INTEGER PRIMARY KEY, id INTEGER, auth_token TEXT, email TEXT"

  # Takes success and error callback options, tries
  # to login with model attributes
  login: (form, options) ->
    # Test for existing login
    $.ajax(
      type: 'GET'
      url: 'http://bluecarbon.unepwcmc-012.vm.brightbox.net/admins/me.json'
      success: options.success
      error: (data)=>
        @set('email', form.email)
        if data.error?
          # Not logged in, login
          $.ajax(
            type: 'POST'
            url: 'http://bluecarbon.unepwcmc-012.vm.brightbox.net/my/admins/sign_in.json'
            data:
              admin:
                email: form.email
                password: form.password
            dataType: "json"
            success: (data) =>
              @set('auth_token', data.auth_token)

              @localSave({},
                success: (a,b,c)=>
                  options.success(@)
                  BlueCarbon.bus.trigger('user:gotAuthToken', data.auth_token)
                  BlueCarbon.bus.trigger('user:loggedIn', @)
              )

            error: options.error
          )
        else
          options.error(data)
    )

  logout: (options) ->
    @localDestroy(
      success: ->
        BlueCarbon.bus.trigger('user:gotAuthToken', '')
        options.success()
    )
