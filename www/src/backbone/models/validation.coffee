window.BlueCarbon ||= {}
window.BlueCarbon.Models ||= {}

class BlueCarbon.Models.Validation extends Backbone.SyncableModel
  url: 'http://bluecarbon.unepwcmc-012.vm.brightbox.net/validations.json'

  schema: ->
    "sqlite_id INTEGER PRIMARY KEY, id INTEGER, coordinates TEXT, action TEXT, area_id INTEGER, user_id INTEGER, density TEXT, age TEXT, habitat TEXT, condition TEXT, species TEXT, recorded_at TEXT, notes TEXT"

  name: ->
    return "#{ @get('habitat') } - #{@get('action') } ( #{@get('recorded_at').replace(/-/g, '/')})"

  toJSON: (forRails = true)->
    json = super()
    if forRails
      return {
        validation: json
      }
    else
      return json

  setGeomFromPoints: (points) ->
    points = for point in points
      [point.lng, point.lat]

    points.push points[0]

    @set('coordinates', points)

  geomAsLatLngArray: () ->
    latLngs = []

    for point in @get('coordinates')
      latLngs.push(new L.LatLng(point[1], point[0]))

    return latLngs

  getHumanAttributes: () ->
    humanAttributes = _.clone(@attributes)
    keysToRemove = ["coordinates", "sqlite_id", "area_id", "recorded_at"]

    for key, value of humanAttributes
      unless value?
        keysToRemove.push key
      if @humanEnumMap[key]?
        humanAttributes[key] = @humanEnumMap[key][value]

    for key in keysToRemove
      delete humanAttributes[key]

    return humanAttributes

  humanEnumMap:
    density:
      1: "Sparse (<20% cover)"
      2: "Moderate (20-50% cover)"
      3: "Dense (50-80% cover)"
      4: "Very dense (>80% cover)"
    condition:
      1: "Undisturbed / Intact"
      2: "Degraded"
      3: "Restored / Rehabilitating"
      4: "Afforested/ Created"
      5: "Cleared"
    age:
      1: "Natural Mangrove"
      2: "2-10 yrs old"
      3: "10-25 yrs old"
      4: "25-50 yrs old"
