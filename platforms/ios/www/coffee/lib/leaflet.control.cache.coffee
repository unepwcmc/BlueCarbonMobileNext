class L.Control.OfflineLayer extends L.Control
  initialize: (@offlineLayer) ->

  onAdd: (map) ->
    controls = L.DomUtil.create('div', 'control-button', this._container)

    @cacheButton = L.DomUtil.create('input', 'cache-button', controls)
    @cacheButton.setAttribute('type', "button")
    @cacheButton.setAttribute('id', "Btn1")
    @cacheButton.setAttribute('value', "Cache")

    L.DomEvent.addListener(@cacheButton, 'click', this.onCacheClick, this)
    L.DomEvent.disableClickPropagation(@cacheButton)

    @clearButton = L.DomUtil.create('input', 'offlinemap-controls-clear-button', controls)
    @clearButton.setAttribute('type', "button")
    @clearButton.setAttribute('id', "clearBtn")
    @clearButton.setAttribute('value', "Clear DB")

    L.DomEvent.addListener(@clearButton, 'click', this.onClearClick, this)
    L.DomEvent.disableClickPropagation(@clearButton)

    return controls

  onClearClick: () =>
    @offlineLayer.clearTiles(
      () =>
        alert 'Cleared cache'
      ,
      (error) =>
        alert 'Could not clear cache'
        console.log error
    )

  onCacheClick: () =>
    nbTiles = @offlineLayer.calculateNbTiles(17)
    if nbTiles < 10000
      console.log("Will be saving: " + nbTiles + " tiles")

      @offlineLayer.saveTiles(17,
        () =>
          null
        ,
        () =>
          alert 'Saved cache'
        ,
        (error) =>
          console.log(error)
          alert 'Could not save cache'
      )
    else
      alert("You are trying to save " + nbTiles + " tiles. There is currently a limit of 10,000 tiles.")
