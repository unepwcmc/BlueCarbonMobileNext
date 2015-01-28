window.BlueCarbon ||= {}
window.BlueCarbon.Collections ||= {}

class BlueCarbon.Collections.Validations extends Backbone.SyncableCollection
  model: BlueCarbon.Models.Validation
  initialize: (models, options) ->
    @area = options.area
    super
  
  doSqliteSync: (method, collection, options) =>
    sql = ""
    switch method
      when "read"
        sql =
          """
            SELECT *
            FROM #{collection.model::constructor.name}
            WHERE area_id="#{collection.area.get('id')}";
          """
     
    BlueCarbon.SQLiteDb.transaction(
      (tx) =>
        tx.executeSql(sql, [], (tx, results) =>
          options.success.call(@, results, 'success', tx)
        )
      , (tx, error) =>
        options.error.apply(@, arguments)
    )

  pushToServer: (successCallback, errorCallback)->
    successes = []
    errors = []
    modelCount = @models.length

    # Method to collect validation save states
    onValidationPushed = (validation, state, validationErrors) ->
      return if !successCallback? and !errorCallback? # No point recording if there are no callbacks

      if state == 'success'
        successes.push(validation)
      else
        errors.push({validation: validation, error: validationErrors})
      # Was this the last validation?
      if modelCount == (successes.length + errors.length)
        if errors.length > 0
          errorCallback(errors) if errorCallback?
        else
          successCallback(successes) if successCallback?
      
    @each (validation) ->
      validation.save({},
        success: ->
          onValidationPushed(validation, 'success')
          validation.localDestroy(
            error: (a,b,c) ->
              console.log("failed to delete area with:")
              console.log arguments
          )
        error: (errorModel, response)->
          console.log("failed to upload area with:")
          console.log arguments
          error = response.responseText
          try
            error = JSON.parse(error)
          onValidationPushed(validation, 'error', error)
      )
