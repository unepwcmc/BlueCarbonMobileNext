class BlueCarbon.Controller extends Wcmc.Controller
  constructor: (options)->
    @app = options.app
    @offlineLayer = options.offlineLayer
    @sidePanel = new Backbone.ViewManager('#side-panel')
    @modal = new Backbone.ViewManager('#modal-container')

    @loginUser()

  loginUser: =>
    @user = new BlueCarbon.Models.User()
    loginView = new BlueCarbon.Views.LoginView(model: @user)

    @user.set('id', '1')
    @user.localFetch(
      success: () =>
        if @user.get('auth_token')
          BlueCarbon.bus.trigger('user:loggedIn', @user)
          BlueCarbon.bus.trigger('user:gotAuthToken', @user.get('auth_token'))
        else
          $('#modal-disabler').addClass('active')
          @modal.showView(loginView)
    )

    @transitionToActionOn(BlueCarbon.bus, 'user:loggedIn', =>
      $('#modal-disabler').removeClass('active')
      @areaIndex()
    )

  areaIndex: =>
    areaIndexView = new BlueCarbon.Views.AreaIndexView(map: @app.map, offlineLayer: @offlineLayer)
    @sidePanel.showView(areaIndexView)

    @transitionToActionOn(BlueCarbon.bus, 'area:startTrip', @areaEdit)

  areaEdit: (options) =>
    areaEditView = new BlueCarbon.Views.AreaEditView(area: options.area, map: @app.map)
    @sidePanel.showView(areaEditView)

    @transitionToActionOn(areaEditView, 'addValidation', @addValidation)
    @transitionToActionOn(areaEditView, 'back', @areaIndex)

  addValidation: (options) =>
    addValidationView = new BlueCarbon.Views.AddValidationView(area: options.area, map: @app.map)
    @sidePanel.showView(addValidationView)

    @transitionToActionOn(addValidationView, 'validation:created', @areaEdit)
    @transitionToActionOn(addValidationView, 'back', @areaEdit)
