// Generated by CoffeeScript 1.9.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  Backbone.SyncableModel = (function(_super) {
    __extends(SyncableModel, _super);

    function SyncableModel() {
      this.createTableIfNotExist = __bind(this.createTableIfNotExist, this);
      return SyncableModel.__super__.constructor.apply(this, arguments);
    }

    SyncableModel.prototype.localSave = function(key, val, options) {
      var attrs, current, done, method, model, silentOptions, success, xhr;
      attrs = void 0;
      current = void 0;
      done = void 0;
      if ((key == null) || _.isObject(key)) {
        attrs = key;
        options = val;
      } else {
        if (key != null) {
          (attrs = {})[key] = val;
        }
      }
      options = (options ? _.clone(options) : {});
      if (options.wait) {
        if (attrs && !this._validate(attrs, options)) {
          return false;
        }
        current = _.clone(this.attributes);
      }
      silentOptions = _.extend({}, options, {
        silent: true
      });
      if (attrs && !this.set(attrs, (options.wait ? silentOptions : options))) {
        return false;
      }
      if (!attrs && !this._validate(null, options)) {
        return false;
      }
      model = this;
      success = options.success;
      options.success = function(transaction, results) {
        var serverAttrs;
        done = true;
        serverAttrs = model.localParse(results, transaction);
        if (options.wait) {
          serverAttrs = _.extend(attrs || {}, serverAttrs);
        }
        if (!model.set(serverAttrs, options)) {
          return false;
        }
        if (success) {
          return success(model, results, options);
        }
      };
      method = (this.isNew() ? "create" : (options.patch ? "patch" : "update"));
      if (method === "patch") {
        options.attrs = attrs;
      }
      xhr = this.sqliteSync(method, this, options);
      if (!done && options.wait) {
        this.clear(silentOptions);
        this.set(current, silentOptions);
      }
      return xhr;
    };

    SyncableModel.prototype.localFetch = function(options) {
      var model, success;
      options = (options ? _.clone(options) : {});
      if (options.parse === void 0) {
        options.parse = true;
      }
      model = this;
      success = options.success;
      options.success = function(tx, results) {
        if (!model.set(model.localParse(results, tx), options)) {
          return false;
        }
        if (success) {
          return success(model, results, options);
        }
      };
      return this.sqliteSync("read", this, options);
    };

    SyncableModel.prototype.localDestroy = function(options) {
      var destroy, model, success, xhr;
      options = (options ? _.clone(options) : {});
      model = this;
      success = options.success;
      destroy = function() {
        return model.trigger("destroy", model, model.collection, options);
      };
      options.success = function(resp) {
        if (options.wait || model.isNew()) {
          destroy();
        }
        if (success) {
          return success(model, resp, options);
        }
      };
      xhr = this.sqliteSync("delete", this, options);
      if (!options.wait) {
        destroy();
      }
      return xhr;
    };

    SyncableModel.prototype.sqliteSync = function(method, model, options) {
      return this.createTableIfNotExist({
        success: (function(_this) {
          return function() {
            return _this.doSqliteSync(method, model, options);
          };
        })(this),
        error: (function(_this) {
          return function(error) {
            return options.error(error);
          };
        })(this)
      });
    };

    SyncableModel.prototype.stringifyAndEscapeJson = function(val) {
      val = JSON.stringify(val);
      val = val.replace(/(\")/g, "\\\"");
      return val;
    };

    SyncableModel.prototype.doSqliteSync = function(method, model, options) {
      var attr, attrs, fields, idField, sql, val, values;
      attrs = model.toJSON(false);
      sql = "";
      switch (method) {
        case "create":
          fields = [];
          values = [];
          for (attr in attrs) {
            val = attrs[attr];
            if (_.isFunction(val)) {
              continue;
            }
            if (_.isArray(val) || _.isObject(val)) {
              val = this.stringifyAndEscapeJson(val);
            }
            fields.push(attr);
            values.push("'" + val + "'");
          }
          sql = "INSERT INTO " + model.constructor.name + "\n( " + (fields.join(", ")) + " )\nVALUES ( " + (values.join(", ")) + " );";
          break;
        case "update":
          fields = [];
          values = [];
          for (attr in attrs) {
            val = attrs[attr];
            if (_.isFunction(val)) {
              continue;
            }
            if (_.isArray(val) || _.isObject(val)) {
              val = this.stringifyAndEscapeJson(val);
            }
            fields.push(attr);
            values.push("'" + val + "'");
          }
          sql = "INSERT OR REPLACE INTO " + model.constructor.name + "\n( " + (fields.join(", ")) + " )\nVALUES ( " + (values.join(", ")) + " );";
          break;
        case "read":
          if (attrs['sqlite_id'] != null) {
            idField = 'sqlite_id';
          } else {
            idField = 'id';
          }
          sql = "SELECT *\nFROM " + model.constructor.name + "\nWHERE " + idField + "=\"" + attrs[idField] + "\";";
          break;
        case "delete":
          if (attrs['sqlite_id'] != null) {
            idField = 'sqlite_id';
          } else {
            idField = 'id';
          }
          sql = "DELETE FROM " + model.constructor.name + "\nWHERE " + idField + "=\"" + attrs[idField] + "\";";
      }
      return BlueCarbon.SQLiteDb.transaction((function(_this) {
        return function(tx) {
          return tx.executeSql(sql, [], function(tx, results) {
            options.success.apply(_this, arguments);
            return _this.trigger('sync');
          });
        };
      })(this), (function(_this) {
        return function(tx, error) {
          console.log("Unable to save model:");
          console.log(_this);
          console.log(arguments[0].stack);
          return options.error.apply(_this, arguments);
        };
      })(this));
    };

    SyncableModel.prototype.createTableIfNotExist = function(options) {
      var sql;
      if (this.schema == null) {
        alert("Model " + this.constructor.name + " must implement a this.schema() method, containing a SQLite comma separated string of 'name TYPE, name2 TYPE2...' so the DB can be init");
        return options.error();
      }
      sql = "CREATE TABLE IF NOT EXISTS " + this.constructor.name + " (" + (this.schema()) + ")";
      return BlueCarbon.SQLiteDb.transaction((function(_this) {
        return function(tx) {
          return tx.executeSql(sql, [], function(tx, results) {
            return options.success.apply(_this, arguments);
          });
        };
      })(this), (function(_this) {
        return function(tx, error) {
          console.log("failed to make check exists");
          return options.error.apply(_this, arguments);
        };
      })(this));
    };

    SyncableModel.prototype.localParse = function(results, tx) {
      var modelAttributes;
      modelAttributes = results.rows.item(0);
      _.each(modelAttributes, function(value, key) {
        try {
          if ((typeof value) === 'string') {
            value = value.replace(/(\\\")/g, "\"");
          }
          return modelAttributes[key] = JSON.parse(value);
        } catch (_error) {}
      });
      return modelAttributes;
    };

    return SyncableModel;

  })(Backbone.Model);

}).call(this);
