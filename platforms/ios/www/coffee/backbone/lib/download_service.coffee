class window.DownloadService
  MAX_ZOOM_LEVEL = 17
  constructor: (@area, @offlineLayer) ->
    @completedPercentage = 0
    @totalJobs = 0
    @completedJobs = 0

  downloadArea: ->
    @calculateTotalJobs()

    @downloadHabitats().then(@downloadBaseLayer)

  downloadBaseLayer: =>
    new Promise( (resolve, reject) =>
      @offlineLayer.on('tilecachingprogress', @notifyCompletedJob)
      @offlineLayer.saveTiles(MAX_ZOOM_LEVEL, (->), resolve, reject, @areaBounds())
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
    success = (fileEntry) =>
      @updateArea(layer)
      @notifyCompletedJob()
      callback(null, fileEntry)

    ft = new FileTransfer()
    ft.download layer.url, @area.filenameForLayer(layer), success, callback

  updateArea: (layer) ->
    layer.downloadedAt = (new Date()).getTime()

    mbTiles = @area.get('mbtiles')
    for storedLayer, index in mbTiles
      if storedLayer.habitat == layer.habitat
        mbTiles[index] = layer
    @area.set('mbtiles', mbTiles)
    @area.localSave()

  calculateTotalJobs: ->
    layers = @area.get('mbtiles')
    @totalJobs = (
      @offlineLayer.calculateNbTiles(MAX_ZOOM_LEVEL, @areaBounds()) + layers.length
    )

  notifyCompletedJob: =>
    @completedJobs += 1
    @completedPercentage = (@completedJobs * 100) / @totalJobs

    @onPercentageChange?(@completedPercentage)

  areaBounds: ->
    areaBounds = L.latLngBounds(@area.coordsAsLatLngArray())
    areaZoom = @offlineLayer._map.getBoundsZoom(areaBounds)
    min = @offlineLayer._map.project(areaBounds.getNorthWest(), areaZoom)
    max = @offlineLayer._map.project(areaBounds.getSouthEast(), areaZoom)

    {min: min , max: max}

