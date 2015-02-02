// Generated by CoffeeScript 1.9.0
(function() {
  var _base,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  window.BlueCarbon || (window.BlueCarbon = {});

  (_base = window.BlueCarbon).Views || (_base.Views = {});

  BlueCarbon.Views.AreaIndexView = (function(_super) {
    __extends(AreaIndexView, _super);

    function AreaIndexView() {
      this.render = __bind(this.render, this);
      return AreaIndexView.__super__.constructor.apply(this, arguments);
    }

    AreaIndexView.prototype.template = JST['area/area_index'];

    AreaIndexView.prototype.className = 'area-index';

    AreaIndexView.prototype.events = {
      "click .sync-areas": "sync"
    };

    AreaIndexView.prototype.initialize = function(options) {
      this.map = options.map;
      this.offlineLayer = options.offlineLayer;
      this.areaList = new BlueCarbon.Collections.Areas();
      this.areaList.on('reset', this.render);
      this.sync();
      return this.subViews = [];
    };

    AreaIndexView.prototype.render = function() {
      this.$el.html(this.template({
        models: this.areaList.toJSON()
      }));
      this.closeSubViews();
      this.areaList.each((function(_this) {
        return function(area) {
          var areaView;
          areaView = new BlueCarbon.Views.AreaView({
            area: area,
            map: _this.map,
            offlineLayer: _this.offlineLayer
          });
          $('#area-list').append(areaView.render().el);
          return _this.subViews.push(areaView);
        };
      })(this));
      return this;
    };

    AreaIndexView.prototype.sync = function() {
      return this.areaList.localFetch({
        success: (function(_this) {
          return function() {
            _this.showUpdating();
            return _this.areaList.fetch({
              success: function() {
                _this.areaList.localSave();
                return _this.showUpdated();
              }
            });
          };
        })(this),
        error: (function(_this) {
          return function(a, b, c) {
            console.log("local fetch fail:");
            console.log(arguments);
            return console.log(arguments[0].stack);
          };
        })(this)
      });
    };

    AreaIndexView.prototype.showUpdating = function() {
      return $('#sync-status').text("Syncing area list...");
    };

    AreaIndexView.prototype.showUpdated = function() {
      return $('#sync-status').text("Area list updated");
    };

    AreaIndexView.prototype.closeSubViews = function() {
      var view, _i, _len, _ref, _results;
      _ref = this.subViews;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        view = _ref[_i];
        _results.push(view.close());
      }
      return _results;
    };

    AreaIndexView.prototype.onClose = function() {
      this.areaList.off('reset', this.render);
      return this.closeSubViews();
    };

    return AreaIndexView;

  })(Backbone.View);

  BlueCarbon.Views.AreaView = (function(_super) {
    __extends(AreaView, _super);

    function AreaView() {
      this.zoomToBounds = __bind(this.zoomToBounds, this);
      this.downloadData = __bind(this.downloadData, this);
      this.startTrip = __bind(this.startTrip, this);
      this.render = __bind(this.render, this);
      return AreaView.__super__.constructor.apply(this, arguments);
    }

    AreaView.prototype.template = JST['area/area'];

    AreaView.prototype.tagName = 'li';

    AreaView.prototype.events = {
      "click .download-data": "downloadData",
      "click .start-trip": "startTrip",
      "click": "zoomToBounds"
    };

    AreaView.prototype.initialize = function(options) {
      this.area = options.area;
      this.offlineLayer = options.offlineLayer;
      this.area.on('sync', this.render);
      return this.map = options.map;
    };

    AreaView.prototype.render = function() {
      console.log("calling render");
      this.$el.html(this.template({
        area: this.area
      }));
      if (this.mapPolygon != null) {
        this.map.removeLayer(this.mapPolygon);
      }
      this.mapPolygon = new L.Polygon(this.area.coordsAsLatLngArray(), {
        opacity: 0.5,
        color: '#E2E2E2',
        weight: 3,
        dashArray: [5, 5]
      });
      this.mapPolygon.addTo(this.map);
      return this;
    };

    AreaView.prototype.startTrip = function() {
      return BlueCarbon.bus.trigger('area:startTrip', {
        area: this.area
      });
    };

    AreaView.prototype.downloadData = function() {
      this.zoomToBounds();
      return this.map.once('moveend', (function(_this) {
        return function() {
          var service;
          service = new DownloadService(_this.area);
          return service.downloadHabitats().then(function() {
            return service.downloadBaseLayer(_this.offlineLayer);
          }).then(function() {})["catch"](function(error) {
            alert('Could not download the area');
            return console.log(error);
          });
        };
      })(this));
    };

    AreaView.prototype.zoomToBounds = function() {
      var bounds;
      bounds = this.area.coordsAsLatLngArray();
      return this.map.fitBounds(bounds);
    };

    AreaView.prototype.onClose = function() {
      return this.map.removeLayer(this.mapPolygon);
    };

    return AreaView;

  })(Backbone.View);

}).call(this);
