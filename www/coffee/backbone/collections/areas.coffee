window.BlueCarbon ||= {}
window.BlueCarbon.Collections ||= {}

class BlueCarbon.Collections.Areas extends Backbone.SyncableCollection
  model: BlueCarbon.Models.Area

  url: 'http://bluecarbon.unepwcmc-012.vm.brightbox.net/areas.json'

  doSqliteSync: (method, collection, options) =>
    sql = ""
    switch method
      when "read"
        sql =
          """
            SELECT *
            FROM #{collection.model::constructor.name}
          """

    BlueCarbon.SQLiteDb.transaction(
      (tx) =>
        tx.executeSql(sql, [], (tx, results) =>
          options.success.call(@, results, 'success', tx)
        )
      , (tx, error) =>
        options.error.apply(@, arguments)
    )

  parse: (data, response)->
    # Don't overwrite attributes from local storage on HTTP sync
    for fetchedArea in data
      # Try to find the corresponding area in current object
      areaModel = null
      for localAreaModel in @models
        if localAreaModel.get('id') == fetchedArea.id
          areaModel = localAreaModel
          break

      if areaModel?
        # Copy the downloaded date for each layer from local data to fetched server data
        for fetchedLayer in fetchedArea.mbtiles
          # Find corresponding local layer
          for localLayer in areaModel.get('mbtiles')
            if localLayer.habitat == fetchedLayer.habitat
              # Copy local storage attributes to fetchedData
              fetchedLayer.downloadedAt = localLayer.downloadedAt
              break


    super
