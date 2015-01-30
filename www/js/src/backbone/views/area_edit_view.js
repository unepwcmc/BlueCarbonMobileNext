// Generated by CoffeeScript 1.9.0
(function() {
  var _base,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  window.BlueCarbon || (window.BlueCarbon = {});

  (_base = window.BlueCarbon).Views || (_base.Views = {});

  BlueCarbon.Views.AreaEditView = (function(_super) {
    __extends(AreaEditView, _super);

    function AreaEditView() {
      this.onClose = __bind(this.onClose, this);
      this.drawSubViews = __bind(this.drawSubViews, this);
      this.render = __bind(this.render, this);
      this.showUploadErrors = __bind(this.showUploadErrors, this);
      this.showSuccessfulUploadNotice = __bind(this.showSuccessfulUploadNotice, this);
      return AreaEditView.__super__.constructor.apply(this, arguments);
    }

    AreaEditView.prototype.template = JST['area/edit'];

    AreaEditView.prototype.events = {
      "touchend #new-validation": "fireAddValidation",
      "touchend #upload-validations": "uploadValidations",
      "touchend .ios-head .back": "fireBack"
    };

    AreaEditView.prototype.initialize = function(options) {
      this.area = options.area;
      this.map = options.map;
      this.validationList = new BlueCarbon.Collections.Validations([], {
        area: this.area
      });
      this.validationList.on('reset', this.render);
      this.validationList.localFetch();
      this.subViews = [];
      this.showAreaExtentPolyline();
      this.addMapLayers(this.area, this.map);
      return this.addLayerControl(this.map);
    };

    AreaEditView.prototype.showAreaExtentPolyline = function() {
      this.extentPolyline = new L.Polyline(this.area.coordsAsLatLngArray(), {
        opacity: 0.3,
        color: '#E2E2E2',
        weight: 3,
        dashArray: [5, 5]
      });
      return this.extentPolyline.addTo(this.map);
    };

    AreaEditView.prototype.removeAreaExtentPolyline = function() {
      return this.map.removeLayer(this.extentPolyline);
    };

    AreaEditView.prototype.fireAddValidation = function() {
      return this.trigger('addValidation', {
        area: this.area
      });
    };

    AreaEditView.prototype.fireBack = function() {
      return this.trigger('back');
    };

    AreaEditView.prototype.uploadValidations = function() {
      if (navigator.connection.type === Connection.NONE) {
        alert("You need to connect to the internet before you can upload validations");
        return false;
      }
      this.uploading = true;
      this.render();
      return this.validationList.pushToServer(this.showSuccessfulUploadNotice, this.showUploadErrors);
    };

    AreaEditView.prototype.showSuccessfulUploadNotice = function(validations) {
      alert("Successfully pushed " + validations.length + " validation(s) to server.\nYou will need to re-download the habitat data for this area before making more edits");
      return this.trigger('back');
    };

    AreaEditView.prototype.showUploadErrors = function(errors) {
      var errorText, key, validationError, value, _i, _len, _ref;
      this.uploading = false;
      this.render();
      errorText = "";
      for (_i = 0, _len = errors.length; _i < _len; _i++) {
        validationError = errors[_i];
        errorText += "<li>\n  Failed to upload '" + (validationError.validation.name()) + "':";
        if (typeof validationError.error === 'object') {
          errorText += "<ul>";
          _ref = validationError.error;
          for (key in _ref) {
            value = _ref[key];
            errorText += "<li><b>" + key + "</b>: " + value + "</li>";
          }
          errorText += "</ul>";
        } else {
          errorText += "<br/>" + validationError.error;
        }
        errorText += "</li>";
      }
      return this.$el.append("<div class='error-notice'><ul>" + errorText + "</ul></div>");
    };

    AreaEditView.prototype.render = function() {
      this.$el.html(this.template({
        area: this.area,
        validationCount: this.validationList.models.length,
        uploading: this.uploading
      }));
      this.drawSubViews();
      return this;
    };

    AreaEditView.prototype.drawSubViews = function() {
      if ($('#validation-list').length > 0) {
        this.closeSubViews();
        return this.validationList.each((function(_this) {
          return function(validation) {
            var validationView;
            validationView = new BlueCarbon.Views.ValidationView({
              validation: validation
            });
            _this.subViews.push(validationView);
            return $('#validation-list').append(validationView.render().el);
          };
        })(this));
      } else {
        this.validationListObserver = new WebKitMutationObserver((function(_this) {
          return function(mutations, observer) {
            _this.drawSubViews();
            return observer.disconnect();
          };
        })(this));
        return this.validationListObserver.observe(document, {
          subtree: true,
          childList: true
        });
      }
    };

    AreaEditView.prototype.onClose = function() {
      this.validationList.off('reset', this.render);
      this.closeSubViews();
      if (this.validationListObserver) {
        this.validationListObserver.disconnect();
      }
      this.removeTileLayers(this.map);
      this.removeLayerControl(this.map);
      return this.removeAreaExtentPolyline();
    };

    AreaEditView.prototype.closeSubViews = function() {
      var view, _results;
      _results = [];
      while ((view = this.subViews.pop()) != null) {
        _results.push(view.close());
      }
      return _results;
    };

    return AreaEditView;

  })(Backbone.View);

  _.extend(BlueCarbon.Views.AreaEditView.prototype, BlueCarbon.Mixins.AreaMapLayers);

}).call(this);
