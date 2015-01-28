window.BlueCarbon ||= {}
window.BlueCarbon.Views ||= {}

class BlueCarbon.Views.ValidationView extends Backbone.View
  template: JST['area/validation']
  tagName: 'li'
  events:
    "click .delete-validation" : "delete"
    "touchstart .validation-title" : "toggleDetails"

  initialize: (options)->
    @detailsVisible = false
    @validation = options.validation
    @validation.on('destroy', =>
      @close()
    )
    BlueCarbon.bus.on('validation-views:hideDetails', @hideDetails)

    @map = window.blueCarbonApp.map
    polyOptions = {}
    if @validation.get('action') == 'delete'
      polyOptions =
        color: "#FF0000"
        strokeColor: "#FF0000"
    @mapPolygon = new L.Polygon(@validation.geomAsLatLngArray(), polyOptions)

  render: =>
    @$el.html(@template(validation:@validation, humanAttributes: @validation.getHumanAttributes()))
    @mapPolygon.addTo(@map)
    return @

  toggleDetails: =>
    if @detailsVisible
      @hideDetails()
    else
      BlueCarbon.bus.trigger('validation-views:hideDetails')
      @$el.find('.validation-details').slideDown()
      @showHighlightPolygon()
      @detailsVisible = true
  
  hideDetails: =>
    if @detailsVisible
      @$el.find('.validation-details').slideUp()
      @removeHighlightPolygon()
      @detailsVisible = false

  showHighlightPolygon: ->
    unless @highlightPolygon?
      @highlightPolygon = new L.Polygon(@validation.geomAsLatLngArray(),
        opacity: 0.9
        color: '#00FFFF'
        fillColor: '#00FFFF'
      )
      @highlightPolygon.addTo(@map)

  removeHighlightPolygon: ->
    if @highlightPolygon?
      @map.removeLayer(@highlightPolygon)
      delete @highlightPolygon

  delete: =>
    if confirm('are you sure you want to delete this validation?')
      @validation.localDestroy()

  onClose: ->
    @map.removeLayer(@mapPolygon)
    @removeHighlightPolygon()
    BlueCarbon.bus.off('validation-views:hideDetails', @hideDetails)

