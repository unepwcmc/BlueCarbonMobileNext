class Backbone.SyncableCollection extends Backbone.Collection
  localFetch: (options) ->
    # This method copies the default backbone behavior, 
    # but uses our sqliteSync instead of backbone.sync
    options = (if options then _.clone(options) else {})
    options.parse = false
    collection = this
    success = options.success
    options.success = (results,status,transaction) ->
      method = (if options.update then "update" else "reset")
      collection[method] collection.localParse(results, transaction), options
      success collection, status, options  if success

    @sqliteSync "read", this, options

  localSave: (options) ->
    @emptyDb(
      success: =>
        @each((model)->
          model.localSave({},
            error: (a,b,c) ->
              console.log "error saving model:"
              console.log model
              console.log arguments
              #console.log arguments[0].stack
          )
        )
      error: (a,b,c)->
        alert('unable to clear db')
    )

  sqliteSync: (method, collection, options) ->
    Backbone.SyncableModel::createTableIfNotExist.call(
      collection.model::,
        success: =>
          @doSqliteSync(method, collection, options)
        error: (a,b,c) =>
          console.log("Error confirming existence of DB for collection #{collection.model.constructor.name}:")
          console.log arguments
          options.error(error)
    )

  localParse: (results,tx)->
    i = 0
    jsonResults = []
    while results.rows.item(i)
      modelAttributes = results.rows.item(i)
      _.each modelAttributes, (value, key) ->
        try
          value = value.replace(/(\\\")/g, "\"") if (typeof value) == 'string'
          modelAttributes[key] = JSON.parse(value)
        catch err

      jsonResults.push(modelAttributes)
      i = i + 1
    return jsonResults

  doSqliteSync: (method, collection, options) =>
    alert("Collection #{collection.constructor.name} must implement a doSqliteSync method which provides backbone.sync behavior, but to SQL")

  emptyDb: (options)->
    sql = "DELETE FROM #{@model.name}"
    BlueCarbon.SQLiteDb.transaction(
      (tx) =>
        tx.executeSql(sql, [], (tx, results) =>
          options.success.apply(@, arguments)
        )
      , (tx, error) =>
        console.log "Unable to empty database #{@model.name}"
        options.error.apply(@, arguments)
    )
