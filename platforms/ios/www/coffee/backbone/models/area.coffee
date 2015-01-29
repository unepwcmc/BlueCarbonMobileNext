window.BlueCarbon ||= {}
window.BlueCarbon.Models ||= {}

class BlueCarbon.Models.Area extends Backbone.SyncableModel
  schema: ->
    "id INTEGER, title TEXT, coordinates TEXT, mbtiles TEXT, error TEXT, PRIMARY KEY (id)"

  downloadLayer: (layer, callback) =>
    @pendingDownloads.push layer.habitat

    boundSuccess = (() =>
      _layer = layer
      return (fileEntry)=>
        @layerDownloaded(_layer, fileEntry)
        callback()
    )()
    boundError = (() =>
      _layer = layer
      return (error) =>
        console.log "unable to download #{_layer.habitat}"
        @pendingDownloads.splice(@pendingDownloads.indexOf(layer.habitat), 1)
        console.log error
        callback(error)
    )()

    ft = new FileTransfer()
    ft.download layer.url, @filenameForLayer(layer), boundSuccess, boundError

  downloadData: (@offlineLayer, callback) =>
    @pendingDownloads = []
    async.parallel([@downloadLayers, @downloadTiles], callback)

  downloadLayers: (callback) =>
    async.map(@get('mbtiles'), @downloadLayer, callback)

  downloadTiles: (callback) =>
    @offlineLayer.saveTiles(17,
        () =>
          @downloadingTiles = true
        ,
        () =>
          @downloadingTiles = false
          alert 'Saved cache'
          callback()
        ,
        (error) =>
          @downloadingTiles = false
          console.log(error)
          alert 'Could not save cache'
          callback(error)
      )



  filenameForLayer: (layer, absolute=true) ->
    name = ""
    name += "#{cordova.file.documentsDirectory}" if absolute
    name += "#{@get('id')}-#{layer.habitat}.mbtiles"
    name

  layerDownloaded: (layer, fileEntry) =>
    console.log "downloaded #{layer.habitat}"
    @pendingDownloads.splice(@pendingDownloads.indexOf(layer.habitat), 1)

    layer.downloadedAt = (new Date()).getTime()
    mbTiles = @get('mbtiles')
    for storedLayer, index in mbTiles
      if storedLayer.habitat == layer.habitat
        mbTiles[index] = layer
    @set('mbtiles', mbTiles)
    @localSave()

  downloadState: () ->
    return "downloading" if (@pendingDownloads?.length > 0 or @downloadingTiles)
    for layer in @get('mbtiles')
      if layer.status == 'pending' || layer.status == 'generating'
        return 'data generating'
      if !layer.downloadedAt?
        return 'no data'
      if layer.downloadedAt < Date.parse(layer.last_generated_at)
        return 'out of date'
    return "ready"

  lastDownloaded: ->
    lowestDownloaded = ""
    for layer in @get('mbtiles')
      if layer.downloadedAt?
        if !_.isNumber(lowestDownloaded) || layer.downloadedAt < lowestDownloaded
          lowestDownloaded = layer.downloadedAt
    if (typeof lowestDownloaded) == 'string'
      return ""
    else
      lowestDownloaded = new Date(lowestDownloaded)
      return "#{lowestDownloaded.getFullYear()}/#{lowestDownloaded.getMonth()+1}/#{lowestDownloaded.getDate()}"

  tileLayers: ->
    layers = []
    for layer in @get('mbtiles')
      layers.push(
        name: @parseLayerName(layer.habitat)
        mbtileLocation: @filenameForLayer(layer, false)
      )
    return layers

  parseLayerName: (name) ->
    name = name.replace("_", " ")

    _.map(name.split(" "), (name) ->
      name.charAt(0).toUpperCase() + name.slice(1)
    ).join(" ")

  coordsAsLatLngArray: () ->
    latLngs = []

    for point in @get('coordinates')
      latLngs.push(new L.LatLng(point[1], point[0]))
    latLngs.push(latLngs[0])

    return latLngs

  parse: (data)->
    try
      data.coordinates = JSON.parse(data.coordinates)
    data

