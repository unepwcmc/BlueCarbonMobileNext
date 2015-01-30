// Generated by CoffeeScript 1.9.0
(function() {
  var _base,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  window.BlueCarbon || (window.BlueCarbon = {});

  (_base = window.BlueCarbon).Collections || (_base.Collections = {});

  BlueCarbon.Collections.Areas = (function(_super) {
    __extends(Areas, _super);

    function Areas() {
      this.doSqliteSync = __bind(this.doSqliteSync, this);
      return Areas.__super__.constructor.apply(this, arguments);
    }

    Areas.prototype.model = BlueCarbon.Models.Area;

    Areas.prototype.url = 'http://bluecarbon.unepwcmc-012.vm.brightbox.net/areas.json';

    Areas.prototype.doSqliteSync = function(method, collection, options) {
      var sql;
      sql = "";
      switch (method) {
        case "read":
          sql = "SELECT *\nFROM " + collection.model.prototype.constructor.name;
      }
      return BlueCarbon.SQLiteDb.transaction((function(_this) {
        return function(tx) {
          return tx.executeSql(sql, [], function(tx, results) {
            return options.success.call(_this, results, 'success', tx);
          });
        };
      })(this), (function(_this) {
        return function(tx, error) {
          return options.error.apply(_this, arguments);
        };
      })(this));
    };

    Areas.prototype.parse = function(data, response) {
      var areaModel, fetchedArea, fetchedLayer, localAreaModel, localLayer, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2;
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        fetchedArea = data[_i];
        areaModel = null;
        _ref = this.models;
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          localAreaModel = _ref[_j];
          if (localAreaModel.get('id') === fetchedArea.id) {
            areaModel = localAreaModel;
            break;
          }
        }
        if (areaModel != null) {
          _ref1 = fetchedArea.mbtiles;
          for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
            fetchedLayer = _ref1[_k];
            _ref2 = areaModel.get('mbtiles');
            for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
              localLayer = _ref2[_l];
              if (localLayer.habitat === fetchedLayer.habitat) {
                fetchedLayer.downloadedAt = localLayer.downloadedAt;
                break;
              }
            }
          }
        }
      }
      return Areas.__super__.parse.apply(this, arguments);
    };

    return Areas;

  })(Backbone.SyncableCollection);

}).call(this);
