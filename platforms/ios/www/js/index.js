window.onerror = function(message, url, linenumber) {
  alert("JavaScript error: " + message + " on line " + linenumber + " for " + url);
  console.log("JavaScript error: " + message + " on line " + linenumber + " for " + url);
};
var app = {
  // Application Constructor
  initialize: function() {
    this.localFileName =  'vector.mbtiles';
    this.remoteFile =  'https://dl.dropbox.com/u/2324263/vector.mbtiles';

    this.bindEvents();
  },
  // Bind Event Listeners
  //
  // Bind any events that are required on startup. Common events are:
  // 'load', 'deviceready', 'offline', and 'online'.
  bindEvents: function() {
    var _this = this;
    document.addEventListener('deviceready', function() {
      _this.onDeviceReady();
    }, false);
  },
  // deviceready Event Handler
  //
  // The scope of 'this' is the event. In order to call the 'receivedEvent'
  // function, we must explicity call 'app.receivedEvent(...);'
  onDeviceReady: function() {
    var _this = this;
    window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, function (fileSystem) {
      fs = fileSystem;

      var file = fs.root.getFile(_this.localFileName, {create: false}, function () {
        _this.buildMap();
      }, function () {
        console.log('Downloading file...');

        ft = new FileTransfer();
        ft.download(_this.remoteFile, fs.root.fullPath + '/' + _this.localFileName, function (entry) {
          _this.buildMap();
        }, function (error) {
          alert('GError');
          console.log(error);
        });
      });
    });
  },

  buildMap: function() {
    var db = window.sqlitePlugin.openDatabase(this.localFileName, "1.0", "Tiles", 2000000);

    this.map = new L.Map('map', {
      center: new L.LatLng(24.2870, 54.3274),
        zoom: 10
    });

    tileLayer = new L.TileLayer.MBTiles(db, {
      tms: true
    }).addTo(this.map);

    //var polygonDraw = new L.Polygon.Draw(map, {});
    //polygonDraw.enable();
  }
};
