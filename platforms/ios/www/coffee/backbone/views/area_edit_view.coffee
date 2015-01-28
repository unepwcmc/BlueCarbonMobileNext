window.BlueCarbon ||= {}
window.BlueCarbon.Views ||= {}

class BlueCarbon.Views.AreaEditView extends Backbone.View
  template: JST['area/edit']
  events :
    "touchend #new-validation" : "fireAddValidation"
    "touchend #upload-validations" : "uploadValidations"
    "touchend .ios-head .back" : "fireBack"

  initialize: (options) ->
    @area = options.area
    @map = options.map
    @validationList = new BlueCarbon.Collections.Validations([], area: @area)
    @validationList.on('reset', @render)
    @validationList.localFetch()

    @subViews = []

    @showAreaExtentPolyline()
    @addMapLayers(@area, @map)
    @addLayerControl(@map)

  showAreaExtentPolyline: ->
    @extentPolyline = new L.Polyline(@area.coordsAsLatLngArray(),
      opacity: 0.3
      color: '#E2E2E2'
      weight: 3
      dashArray: [5,5]
    )
    @extentPolyline.addTo(@map)

  removeAreaExtentPolyline: ->
    @map.removeLayer(@extentPolyline)

  fireAddValidation: ->
    @trigger('addValidation', area: @area)

  fireBack: ->
    @trigger('back')

  uploadValidations: ->
    if navigator.connection.type == Connection.NONE
      alert("You need to connect to the internet before you can upload validations")
      return false
    
    @uploading = true
    @render()
    @validationList.pushToServer(
      @showSuccessfulUploadNotice,
      @showUploadErrors
    )

  showSuccessfulUploadNotice: (validations)=>
    alert("""
      Successfully pushed #{validations.length} validation(s) to server.
      You will need to re-download the habitat data for this area before making more edits
    """)
    @trigger('back')

  showUploadErrors: (errors)=>
    @uploading = false
    @render()
    errorText = ""
    for validationError in errors
      errorText += """
        <li>
          Failed to upload '#{validationError.validation.name()}':"""
      if typeof validationError.error == 'object'
        errorText += "<ul>"
        for key, value of validationError.error
          errorText += "<li><b>#{key}</b>: #{value}</li>"
        errorText += "</ul>"
      else
        errorText += "<br/>#{validationError.error}"
      errorText += "</li>"
    @$el.append("<div class='error-notice'><ul>#{errorText}</ul></div>")

  render: =>
    @$el.html(@template(area: @area, validationCount: @validationList.models.length, uploading: @uploading))
    @drawSubViews()

    return @

  drawSubViews: =>
    if $('#validation-list').length > 0
      @closeSubViews()
      @validationList.each (validation)=>
        validationView = new BlueCarbon.Views.ValidationView(validation:validation)
        @subViews.push validationView
        $('#validation-list').append(validationView.render().el)
    else
      # If #validation-list hasn't been inserted yet, listen to DOM changes for when it is
      @validationListObserver = new WebKitMutationObserver((mutations, observer) =>
        # fired when a DOM mutation occurs
        # Try this method again, to see if #validation-list exists yet
        @drawSubViews()
        observer.disconnect()
      )
      @validationListObserver.observe(document,
        subtree: true
        childList: true
      )

  onClose: =>
    @validationList.off('reset', @render)
    @closeSubViews()
    @validationListObserver.disconnect() if @validationListObserver
    @removeTileLayers(@map)
    @removeLayerControl(@map)
    @removeAreaExtentPolyline()

  closeSubViews: ->
    while (view = @subViews.pop())?
      view.close()

_.extend(BlueCarbon.Views.AreaEditView::, BlueCarbon.Mixins.AreaMapLayers)
