class window.DownloadService
  MAX_ZOOM_LEVEL = 17
  constructor: (@area) ->

  downloadBaseLayer: (offlineLayer) ->
    new Promise( (resolve, reject) ->
      offlineLayer.saveTiles(MAX_ZOOM_LEVEL, null, resolve, reject)
    )

  downloadHabitats: ->
    new Promise( (resolve, reject) =>
      layers = @area.get('mbtiles')

      async.map(layers, @downloadHabitatTiles, (err, results) ->
        return reject(err) if err?
        resolve(results)
      )
    )

  downloadHabitatTiles: (layer, callback) =>
    success = (fileEntry) ->
      callback(null, fileEntry)

    ft = new FileTransfer()
    ft.download layer.url, @filenameForLayer(layer), success, callback

  filenameForLayer: (layer) ->
    name = "#{cordova.file.documentsDirectory}"
    name += "#{@area.get('id')}-#{layer.habitat}.mbtiles"
