// Generated by CoffeeScript 1.9.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.DownloadService = (function() {
    var MAX_ZOOM_LEVEL;

    MAX_ZOOM_LEVEL = 17;

    function DownloadService(_at_area) {
      this.area = _at_area;
      this.downloadHabitatTiles = __bind(this.downloadHabitatTiles, this);
    }

    DownloadService.prototype.downloadBaseLayer = function(offlineLayer) {
      return new Promise(function(resolve, reject) {
        return offlineLayer.saveTiles(MAX_ZOOM_LEVEL, (function() {}), resolve, reject);
      });
    };

    DownloadService.prototype.downloadHabitats = function() {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var layers;
          layers = _this.area.get('mbtiles');
          return async.map(layers, _this.downloadHabitatTiles, function(err, results) {
            if (err != null) {
              return reject(err);
            }
            return resolve(results);
          });
        };
      })(this));
    };

    DownloadService.prototype.downloadHabitatTiles = function(layer, callback) {
      var ft, success;
      success = (function(_this) {
        return function(fileEntry) {
          _this.updateArea(layer);
          return callback(null, fileEntry);
        };
      })(this);
      ft = new FileTransfer();
      return ft.download(layer.url, this.area.filenameForLayer(layer), success, callback);
    };

    DownloadService.prototype.updateArea = function(layer) {
      var index, mbTiles, storedLayer, _i, _len;
      layer.downloadedAt = (new Date()).getTime();
      mbTiles = this.area.get('mbtiles');
      for (index = _i = 0, _len = mbTiles.length; _i < _len; index = ++_i) {
        storedLayer = mbTiles[index];
        if (storedLayer.habitat === layer.habitat) {
          mbTiles[index] = layer;
        }
      }
      this.area.set('mbtiles', mbTiles);
      return this.area.localSave();
    };

    return DownloadService;

  })();

}).call(this);