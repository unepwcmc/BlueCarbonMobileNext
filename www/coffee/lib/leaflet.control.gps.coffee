L.Control.ShowLocation = L.Control.extend(
  options:
    position: 'topright'
    text: ''
    iconUrl: 'css/images/location_finder.png'

  onAdd: (map) ->
    @showLocation = false
    @container = L.DomUtil.create('div', 'leaflet-gps-controls')
    @render()

    @map = map

    return @container

  jumpToCurrentLocation: (e) ->
    navigator.geolocation.getCurrentPosition((position)=>
      @moveCenter(position)
      @drawLocation(position) if @showLocation
    , (-> ), {enableHighAccuracy: true})

  moveCenter: (position) ->
    latlng = [
      position.coords.latitude,
      position.coords.longitude
    ]
    @map.panTo(latlng)

  toggleLocationTracking: (e) ->
    @showLocation = !@showLocation
    if @showLocation
      @trackingToggler.setAttribute('src', 'css/images/show.png')
      @startTracking()
    else
      @trackingToggler.setAttribute('src', 'css/images/hide.png')
      @stopTracking()

  drawLocation: (position) ->
    if @marker?
      @map.removeLayer(@marker)

    GpsIcon = L.Icon.extend(
      options:
        iconUrl: 'css/images/gps-marker.png'
        iconSize: [16, 16]
    )

    gpsIcon = new GpsIcon()

    latlng = [
      position.coords.latitude,
      position.coords.longitude
    ]

    @marker = L.marker(latlng, {icon: gpsIcon}).addTo(@map)

    @marker.on('click', (=> @toggleLocationTracking()))

  updateMarker: ->
    navigator.geolocation.getCurrentPosition(((position)=> @drawLocation(position)), (->
      console.log("unable to get current location: ")
      console.log arguments
    ), {enableHighAccuracy: true})

  startTracking: () ->
    unless @geoWatchId?
      @updateMarker()
      @geoWatchId = setInterval((=> @updateMarker()), 30000)

  stopTracking: () ->
    if @geoWatchId?
      clearInterval(@geoWatchId)
      @geoWatchId = null

    if @marker?
      @map.removeLayer(@marker)

  render: () ->
    button = L.DomUtil.create('div', 'leaflet-buttons-control-button', @container)

    image = L.DomUtil.create('img', 'leaflet-buttons-jump-to-location-img', button)
    image.setAttribute('src', @options.iconUrl)

    @trackingToggler = L.DomUtil.create('img', 'leaflet-buttons-gps-show-hide', @container)
    @trackingToggler.setAttribute('src', 'css/images/hide.png')

    if @options.text != ''
      span = L.DomUtil.create('span', 'leaflet-buttons-control-text', button)
      text = document.createTextNode(@options.text)
      span.appendChild(text)

    L.DomEvent
      .addListener(button, 'click', L.DomEvent.stop)
      .addListener(button, 'touchstart', @jumpToCurrentLocation, this)
      .addListener(@trackingToggler, 'click', L.DomEvent.stop)
      .addListener(@trackingToggler, 'touchstart', @toggleLocationTracking, this)

    L.DomEvent.disableClickPropagation(button)
)
