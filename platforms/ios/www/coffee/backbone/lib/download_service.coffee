class window.DownloadService
  MAX_ZOOM_LEVEL = 17
  constructor: (@area, @offlineLayer) ->
    @completedPercentage = 0
    @totalJobs = 0
    @completedJobs = 0

  downloadArea: ->
    @removeExistingTiles().then(@downloadBaseLayer).then(@downloadHabitats)

  downloadBaseLayer: =>
    new Promise( (resolve, reject) =>
      @offlineLayer.on('tilecachingprogress', @notifyCompletedJob)
      @offlineLayer.on('tilecachingprogressstart', @calculateTotalJobs)
      @offlineLayer.saveTiles(MAX_ZOOM_LEVEL, (->), resolve, reject, @area.bounds())
    )

  downloadHabitats: =>
    new Promise( (resolve, reject) =>
      layers = @area.get('mbtiles')

      async.map(layers, @downloadHabitatTiles, (err, results) ->
        return reject(err) if err?
        resolve(results)
      )
    )

  downloadHabitatTiles: (layer, callback) =>
    @updateArea(layer)

    success = (fileEntry) =>
      @area.localSave()
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

  removeExistingTiles: ->
    new Promise( (resolve, reject) =>
      layers = @area.get('mbtiles')

      async.each(layers, @deleteFile, (err, results) ->
        return reject(err) if err?
        resolve(results)
      )
    )

  deleteFile: (layer, callback) =>
    filename = @area.filenameForLayer(layer, false)
    window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, ( (fs) ->
      fs.root.getFile(filename, {}, ( (fileEntry) ->
        fileEntry.remove((-> callback()), callback)
      ), (-> callback()))
    ), callback)

  calculateTotalJobs: (opts) =>
    layers = @area.get('mbtiles')
    @totalJobs = opts.nbTiles + layers.length

  notifyCompletedJob: =>
    @completedJobs += 1
    @completedPercentage = (@completedJobs / @totalJobs) * 100
    console.log "#{@completedJobs}/#{@totalJobs} = #{@completedPercentage}"

    @onPercentageChange?(@completedPercentage)

