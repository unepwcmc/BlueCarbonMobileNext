window.onerror = (message, url, linenumber) ->
  console.log "JavaScript error: #{message} on line #{linenumber} for #{url}"
  alert "JavaScript error: #{message} on line #{linenumber} for #{url}"

$.support.cors = true
$.ajaxSetup(
  data:
    auth_token: ''
)

window.Wcmc ||= {}
window.BlueCarbon ||= {}
window.BlueCarbon.bus = _.extend({}, Backbone.Events)
window.BlueCarbon.Models ||= {}
window.BlueCarbon.Controllers ||= {}
window.BlueCarbon.Views ||= {}
window.BlueCarbon.Routers ||= {}

class BlueCarbon.App
  _.extend @::, Backbone.Events

  # Application Constructor
  constructor: (options)->

    @on('mapReady', (offlineLayer) =>
      @controller = new BlueCarbon.Controller(app:@, offlineLayer: offlineLayer)
    )

    # Show logged in details
    BlueCarbon.bus.on('user:loggedIn', (user) =>
      $("#user-area").html("""
        #{user.get('email')} <a id="logout-user" class="btn btn-small">Log Out</a>
      """)

      $('#logout-user').click( =>
        if navigator.connection.type == Connection.NONE
          alert('You cannot logout while offline, please go online before switching user')
          return false

        r=confirm("Are you sure you wish to logout?")
        if (r==true)
          user.logout(
            success: =>
              $("#user-area").html('')
              @controller.transitionToAction(@controller.loginUser)
          )
      )
    )

    # Setup ajax calls to use auth tokens
    BlueCarbon.bus.on('user:gotAuthToken', (token) ->
      if token != ''
        console.log("logged in, using auth token #{token}")
      else
        console.log("logged out, unsetting auth token")

      # Session persistence
      $.ajaxSetup(
        data:
          auth_token: token
        beforeSend: (xhr, settings) ->
          if (settings.type == 'POST')
            try
              settings.data = JSON.parse settings.data
              settings.data.auth_token = token
              settings.data = JSON.stringify settings.data
      )
    )

    unless options.waitForRemoteConsole
      document.addEventListener "deviceready", @start, false

  start: =>
    StatusBar.hide()

    window.BlueCarbon.SQLiteDb = window.sqlitePlugin.openDatabase(name:"BlueCarbon.db", iosDatabaseLocation: "Documents")

    @map = new L.Map("map",
      center: new L.LatLng(24.2870, 54.3274)
      zoom: 10
      doubleClickZoom: false
      attributionControl: false
    )

    @createBaseLayer()
    @addControls()
    @addBlurListener()

  addBlurListener: ->
    $('body').on('blur', 'input, textarea', ->
      $(window).scrollTop(0)
    )

  addControls: (offlineLayer) ->
    @map.addControl(new L.Control.ShowLocation())
    L.control.scale().addTo(@map)

  createBaseLayer: ->
    tileLayerUrl = 'https://api.mapbox.com/v4/unepwcmc.d8952968/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoidW5lcHdjbWMiLCJhIjoiRXg1RERWRSJ9.taTsSWwtAfFX_HMVGo2Cug'

    options =
      maxZoom: 17,
      storeName: "offlineTileStore",
      dbOption: "WebSQL",
      onReady: ( => @addBaseLayer(offlineLayer) ),
      onError: ->

    offlineLayer = new OfflineLayer(tileLayerUrl, options)

  addBaseLayer: (offlineLayer) ->
    offlineLayer.addTo(@map)
    @trigger('mapReady', offlineLayer)
