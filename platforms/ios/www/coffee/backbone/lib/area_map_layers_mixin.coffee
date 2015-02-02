# Mixin designed for views, adds area map layer behavior
# Add to a view using:
#   _.extend(MyView, BlueCarbon.Mixins.AreaMapLayers)
window.BlueCarbon ||= {}
window.BlueCarbon.Mixins ||= {}

BlueCarbon.Mixins.AreaMapLayers =
  addMapLayers: (area, map)->
    @removeTileLayers()
    @tileLayers ||= {}
    for layer in area.tileLayers()
      db = window.sqlitePlugin.openDatabase(layer.mbtileLocation, "1.0", "Tiles", 2000000)
      tileLayer = new L.TileLayer.MBTiles(db,
        tms: true
      ).addTo(map)
      @tileLayers["<span class='layer-legend #{layer.name}'>#{layer.name}</span>"] = tileLayer

  addLayerControl: (map) ->
    return unless @tileLayers?

    @removeLayerControl(map)

    @layerControl = L.control.layers([], @tileLayers, position: 'bottomright')
    @layerControl.addTo(map)

  removeTileLayers: (map)->
    console.log "removing tile layers"
    if @tileLayers?
      for layerName, layer of @tileLayers
        map.removeLayer(layer)

  removeLayerControl: (map) ->
    if @layerControl?
      map.removeControl(@layerControl)
