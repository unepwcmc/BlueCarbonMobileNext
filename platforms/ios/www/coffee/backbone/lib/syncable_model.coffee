# Extends backbone model to support persistence in a local
# SQLite database
class Backbone.SyncableModel extends Backbone.Model
  localSave: (key, val, options) ->
    # This method copies the default backbone behavior, 
    # but uses our sqliteSync instead of backbone.sync
    attrs = undefined
    current = undefined
    done = undefined
    if not key? or _.isObject(key)
      attrs = key
      options = val
    else (attrs = {})[key] = val  if key?
    options = (if options then _.clone(options) else {})

    # If we're "wait"-ing to set changed attributes, validate early.
    if options.wait
      return false  if attrs and not @_validate(attrs, options)
      current = _.clone(@attributes)

    # Regular saves `set` attributes before persisting to the server.
    silentOptions = _.extend({}, options,
      silent: true
    )
    return false  if attrs and not @set(attrs, (if options.wait then silentOptions else options))

    # Do not persist invalid models.
    return false  if not attrs and not @_validate(null, options)

    # After a successful db save, the client is (optionally)
    # updated with the server-side state.
    model = this
    success = options.success
    options.success = (transaction, results) ->
      done = true
      serverAttrs = model.localParse(results, transaction)
      serverAttrs = _.extend(attrs or {}, serverAttrs)  if options.wait
      return false  unless model.set(serverAttrs, options)
      success model, results, options  if success

    # Finish configuring and sending the Ajax request.
    method = (if @isNew() then "create" else ((if options.patch then "patch" else "update")))
    options.attrs = attrs  if method is "patch"
    xhr = @sqliteSync(method, this, options)
    # When using `wait`, reset attributes to original values unless
    # `success` has been called already.
    if not done and options.wait
      @clear silentOptions
      @set current, silentOptions
    xhr

  localFetch: (options) ->
    # This method copies the default backbone behavior, 
    # but uses our sqliteSync instead of backbone.sync
    options = (if options then _.clone(options) else {})
    options.parse = true  if options.parse is undefined
    model = this
    success = options.success
    options.success = (tx, results) ->
      return false  unless model.set(model.localParse(results, tx), options)
      success model, results, options  if success

    @sqliteSync "read", this, options
  
  localDestroy: (options)->
    # This method copies the default backbone behavior, 
    # but uses our sqliteSync instead of backbone.sync
    options = (if options then _.clone(options) else {})
    model = this
    success = options.success
    destroy = ->
      model.trigger "destroy", model, model.collection, options

    options.success = (resp) ->
      destroy()  if options.wait or model.isNew()
      success model, resp, options  if success

    xhr = @sqliteSync("delete", this, options)
    destroy()  unless options.wait
    xhr

  sqliteSync: (method, model, options) ->
    @createTableIfNotExist(
      success: =>
        @doSqliteSync(method, model, options)
      error: (error) =>
        options.error(error)
    )

  stringifyAndEscapeJson: (val) ->
    val = JSON.stringify(val)
    val = val.replace(/(\")/g, "\\\"")
    return val

  doSqliteSync: (method, model, options) ->
    attrs = model.toJSON(false)

    sql = ""
    switch method
      when "create"
        fields = []
        values = []

        for attr, val of attrs
          continue if _.isFunction(val)
          if _.isArray(val) or _.isObject(val)
            val = @stringifyAndEscapeJson(val)

          fields.push(attr)
          values.push("'#{val}'")

        sql =
          """
            INSERT INTO #{model.constructor.name}
            ( #{fields.join(", ")} )
            VALUES ( #{values.join(", ")} );
          """
      when "update"
        fields = []
        values = []

        for attr, val of attrs
          continue if _.isFunction(val)
          if _.isArray(val) or _.isObject(val)
            val = @stringifyAndEscapeJson(val)

          fields.push(attr)
          values.push("'#{val}'")

        sql =
          """
            INSERT OR REPLACE INTO #{model.constructor.name}
            ( #{fields.join(", ")} )
            VALUES ( #{values.join(", ")} );
          """
      when "read"
        if attrs['sqlite_id']?
          idField = 'sqlite_id'
        else
          idField = 'id'
        sql =
          """
            SELECT *
            FROM #{model.constructor.name}
            WHERE #{idField}="#{attrs[idField]}";
          """
      when "delete"
        if attrs['sqlite_id']?
          idField = 'sqlite_id'
        else
          idField = 'id'
        sql =
          """
            DELETE FROM #{model.constructor.name}
            WHERE #{idField}="#{attrs[idField]}";
          """

    BlueCarbon.SQLiteDb.transaction(
      (tx) =>
        tx.executeSql(sql, [], (tx, results) =>
          options.success.apply(@, arguments)
          @trigger('sync')
        )
      , (tx, error) =>
        console.log "Unable to save model:"
        console.log @
        console.log arguments[0].stack
        options.error.apply(@, arguments)
    )

  createTableIfNotExist: (options) =>
    unless @schema?
      alert("Model #{@constructor.name} must implement a this.schema() method, containing a SQLite comma separated string of 'name TYPE, name2 TYPE2...' so the DB can be init")
      return options.error()

    sql = "CREATE TABLE IF NOT EXISTS #{@constructor.name} (#{@schema()})"
    BlueCarbon.SQLiteDb.transaction(
      (tx) =>
        tx.executeSql(sql, [], (tx, results) =>
          options.success.apply(@, arguments)
        )
      , (tx, error) =>
        console.log "failed to make check exists"
        options.error.apply(@, arguments)
    )

  localParse: (results,tx) ->
    modelAttributes = results.rows.item(0)
    _.each modelAttributes, (value, key) ->
      try
        value = value.replace(/(\\\")/g, "\"") if (typeof value) == 'string'
        modelAttributes[key] = JSON.parse(value)

    modelAttributes

