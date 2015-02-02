window.BlueCarbon ||= {}
window.BlueCarbon.Models ||= {}

class BlueCarbon.Models.Area extends Backbone.SyncableModel
  schema: ->
    "id INTEGER, title TEXT, coordinates TEXT, mbtiles TEXT, error TEXT, PRIMARY KEY (id)"

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

  filenameForLayer: (layer, absolute=true) ->
    name = ""
    name += "#{cordova.file.documentsDirectory}" if absolute
    name += "#{@get('id')}-#{layer.habitat}.mbtiles"
    name

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

