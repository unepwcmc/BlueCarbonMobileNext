window.Map = class Map
  constructor: (containerId, options) ->
    options = $.extend({}, options, {
      doubleClickZoom: false,
      attributionControl: false
    })

    options.maxBounds = L.latLngBounds(options.bounds)
    options.center = options.maxBounds.getCenter()

    @map = new L.Map(containerId, options)
    @map.fitBounds(options.maxBounds)

    @createBaseLayer()
    @addControls()

  addControls: (offlineLayer) ->
    @map.addControl(new L.Control.ShowLocation())
    L.control.scale().addTo(@map)

  createBaseLayer: ->
    tileLayerUrl = 'http://{s}.tile.osm.org/{z}/{x}/{y}.png'
    options =
      maxZoom: 18,
      subDomains: ['otile1','otile2','otile3','otile4'],
      storeName: 'offlineTileStore',
      dbOption: 'WebSQL',
      onReady: ( => @addBaseLayer(offlineLayer) ),
      onError: ( -> )

    offlineLayer = new OfflineLayer(tileLayerUrl, options)

  addBaseLayer: (offlineLayer) ->
    offlineLayer.addTo(@map)
    BlueCarbon.bus.trigger('mapReady', offlineLayer)
