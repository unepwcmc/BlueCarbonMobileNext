// Generated by CoffeeScript 1.7.1
(function() {
  L.Control.ShowLocation = L.Control.extend({
    options: {
      position: 'topright',
      text: '',
      iconUrl: 'css/images/location_finder.png'
    },
    onAdd: function(map) {
      this.showLocation = false;
      this.container = L.DomUtil.create('div', 'leaflet-gps-controls');
      this.render();
      this.map = map;
      return this.container;
    },
    jumpToCurrentLocation: function(e) {
      return navigator.geolocation.getCurrentPosition((function(_this) {
        return function(position) {
          _this.moveCenter(position);
          if (_this.showLocation) {
            return _this.drawLocation(position);
          }
        };
      })(this), (function() {}), {
        enableHighAccuracy: true
      });
    },
    moveCenter: function(position) {
      var latlng;
      latlng = [position.coords.latitude, position.coords.longitude];
      return this.map.panTo(latlng);
    },
    toggleLocationTracking: function(e) {
      this.showLocation = !this.showLocation;
      if (this.showLocation) {
        this.trackingToggler.setAttribute('src', 'css/images/show.png');
        return this.startTracking();
      } else {
        this.trackingToggler.setAttribute('src', 'css/images/hide.png');
        return this.stopTracking();
      }
    },
    drawLocation: function(position) {
      var GpsIcon, gpsIcon, latlng;
      if (this.marker != null) {
        this.map.removeLayer(this.marker);
      }
      GpsIcon = L.Icon.extend({
        options: {
          iconUrl: 'css/images/gps-marker.png',
          iconSize: [16, 16]
        }
      });
      gpsIcon = new GpsIcon();
      latlng = [position.coords.latitude, position.coords.longitude];
      this.marker = L.marker(latlng, {
        icon: gpsIcon
      }).addTo(this.map);
      return this.marker.on('click', ((function(_this) {
        return function() {
          return _this.toggleLocationTracking();
        };
      })(this)));
    },
    updateMarker: function() {
      return navigator.geolocation.getCurrentPosition(((function(_this) {
        return function(position) {
          return _this.drawLocation(position);
        };
      })(this)), (function() {
        console.log("unable to get current location: ");
        return console.log(arguments);
      }), {
        enableHighAccuracy: true
      });
    },
    startTracking: function() {
      if (this.geoWatchId == null) {
        this.updateMarker();
        return this.geoWatchId = setInterval(((function(_this) {
          return function() {
            return _this.updateMarker();
          };
        })(this)), 30000);
      }
    },
    stopTracking: function() {
      if (this.geoWatchId != null) {
        clearInterval(this.geoWatchId);
        this.geoWatchId = null;
      }
      if (this.marker != null) {
        return this.map.removeLayer(this.marker);
      }
    },
    render: function() {
      var button, image, span, text;
      button = L.DomUtil.create('div', 'leaflet-buttons-control-button', this.container);
      image = L.DomUtil.create('img', 'leaflet-buttons-jump-to-location-img', button);
      image.setAttribute('src', this.options.iconUrl);
      this.trackingToggler = L.DomUtil.create('img', 'leaflet-buttons-gps-show-hide', this.container);
      this.trackingToggler.setAttribute('src', 'css/images/hide.png');
      if (this.options.text !== '') {
        span = L.DomUtil.create('span', 'leaflet-buttons-control-text', button);
        text = document.createTextNode(this.options.text);
        span.appendChild(text);
      }
      L.DomEvent.addListener(button, 'click', L.DomEvent.stop).addListener(button, 'touchstart', this.jumpToCurrentLocation, this).addListener(this.trackingToggler, 'click', L.DomEvent.stop).addListener(this.trackingToggler, 'touchstart', this.toggleLocationTracking, this);
      return L.DomEvent.disableClickPropagation(button);
    }
  });

}).call(this);