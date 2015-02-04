// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.DownloadService = (function() {
    var MAX_ZOOM_LEVEL;

    MAX_ZOOM_LEVEL = 17;

    function DownloadService(area, offlineLayer) {
      this.area = area;
      this.offlineLayer = offlineLayer;
      this.notifyCompletedJob = __bind(this.notifyCompletedJob, this);
      this.downloadHabitatTiles = __bind(this.downloadHabitatTiles, this);
      this.downloadBaseLayer = __bind(this.downloadBaseLayer, this);
      this.completedPercentage = 0;
      this.totalJobs = 0;
      this.completedJobs = 0;
    }

    DownloadService.prototype.downloadArea = function() {
      this.calculateTotalJobs();
      return this.downloadHabitats().then(this.downloadBaseLayer);
    };

    DownloadService.prototype.downloadBaseLayer = function() {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          _this.offlineLayer.on('tilecachingprogress', _this.notifyCompletedJob);
          return _this.offlineLayer.saveTiles(MAX_ZOOM_LEVEL, (function() {}), resolve, reject);
        };
      })(this));
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
          _this.notifyCompletedJob();
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

    DownloadService.prototype.calculateTotalJobs = function() {
      var layers;
      layers = this.area.get('mbtiles');
      return this.totalJobs = this.offlineLayer.calculateNbTiles(MAX_ZOOM_LEVEL) + layers.length;
    };

    DownloadService.prototype.notifyCompletedJob = function() {
      this.completedJobs += 1;
      this.completedPercentage = (this.completedJobs * 100) / this.totalJobs;
      return typeof this.onPercentageChange === "function" ? this.onPercentageChange(this.completedPercentage) : void 0;
    };

    return DownloadService;

  })();

}).call(this);
