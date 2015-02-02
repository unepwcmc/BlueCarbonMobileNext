window.BlueCarbon ||= {}
window.BlueCarbon.Views ||= {}

class BlueCarbon.Views.AreaIndexView extends Backbone.View
  template: JST['area/area_index']
  className: 'area-index'

  events:
    "click .sync-areas": "sync"

  initialize: (options) ->
    @map = options.map
    @offlineLayer = options.offlineLayer
    @areaList = new BlueCarbon.Collections.Areas()
    @areaList.on('reset', @render)
    @sync()

    @subViews = []

  render: =>
    @$el.html(@template(models:@areaList.toJSON()))
    @closeSubViews()
    @areaList.each (area)=>
      areaView = new BlueCarbon.Views.AreaView(area:area, map: @map, offlineLayer: @offlineLayer)
      $('#area-list').append(areaView.render().el)
      @subViews.push areaView
    return @

  sync: ->
    @areaList.localFetch(
      success: =>
        @showUpdating()
        @areaList.fetch(
          success: =>
            @areaList.localSave() # Write updated list to DB
            @showUpdated()
        )
      error: (a,b,c)=>
        console.log "local fetch fail:"
        console.log arguments
        console.log arguments[0].stack
    )

  showUpdating: ->
    $('#sync-status').text("Syncing area list...")

  showUpdated: ->
    $('#sync-status').text("Area list updated")

  closeSubViews: ->
    for view in @subViews
      view.close()

  onClose: ->
    @areaList.off('reset', @render)
    @closeSubViews()

class BlueCarbon.Views.AreaView extends Backbone.View
  template: JST['area/area']
  tagName: 'li'
  events:
    "click .download-data": "downloadData"
    "click .start-trip": "startTrip"
    "click": "zoomToBounds"

  initialize: (options)->
    @area = options.area
    @offlineLayer = options.offlineLayer

    @area.on('sync', @render)
    @area.on('change:downloadingTiles', @render)

    @map = options.map

  render: =>
    @$el.html(@template(area:@area))
    @map.removeLayer(@mapPolygon) if @mapPolygon?
    @mapPolygon = new L.Polygon(@area.coordsAsLatLngArray(),
      opacity: 0.5
      color: '#E2E2E2'
      weight: 3
      dashArray: [5,5]
    )
    @mapPolygon.addTo(@map)

    return @

  startTrip: =>
    BlueCarbon.bus.trigger('area:startTrip', area: @area)

  downloadData: =>
    @area.set('downloadingTiles', true)
    service = new DownloadService(@area)

    @zoomToBounds().then( =>
      service.downloadHabitats()
    ).then( =>
      service.downloadBaseLayer(@offlineLayer)
    ).then( =>
      alert 'worky work worked'
    ).catch( (error) ->
      alert 'Could not download the area'
      console.log error
    ).finally( =>
      @area.set('downloadingTiles', false)
    )

  zoomToBounds: =>
    new Promise( (resolve, reject) =>
      bounds = @area.coordsAsLatLngArray()
      @map.fitBounds(bounds)
      @map.once('moveend', resolve)
    )

  onClose: ->
    @map.removeLayer(@mapPolygon)
