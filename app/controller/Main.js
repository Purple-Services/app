// Generated by CoffeeScript 1.3.3

Ext.define('Purple.controller.Main', {
  extend: 'Ext.app.Controller',
  config: {
    refs: {
      mainContainer: 'maincontainer',
      topToolbar: 'toptoolbar',
      loginForm: 'loginform',
      requestGasTabContainer: '#requestGasTabContainer',
      mapForm: 'mapform',
      map: '#gmap',
      spacerBetweenMapAndAddress: '#spacerBetweenMapAndAddress',
      requestAddressField: '#requestAddressField',
      requestGasButtonContainer: '#requestGasButtonContainer',
      autocompleteList: '#autocompleteList',
      backToMapButton: '#backToMapButton',
      requestForm: 'requestform',
      requestConfirmationForm: 'requestconfirmationform',
      feedback: 'feedback',
      feedbackTextField: '[ctype=feedbackTextField]',
      feedbackThankYouMessage: '[ctype=feedbackThankYouMessage]',
      invite: 'invite',
      inviteTextField: '[ctype=inviteTextField]',
      inviteThankYouMessage: '[ctype=inviteThankYouMessage]'
    },
    control: {
      mapForm: {
        recenterAtUserLoc: 'recenterAtUserLoc'
      },
      map: {
        centerchange: 'adjustDeliveryLocByLatLng',
        maprender: 'initGeocoder'
      },
      requestAddressField: {
        generateSuggestions: 'generateSuggestions',
        addressInputMode: 'addressInputMode'
      },
      autocompleteList: {
        updateDeliveryLocAddressByLocArray: 'updateDeliveryLocAddressByLocArray'
      },
      backToMapButton: {
        mapMode: 'mapMode',
        recenterAtUserLoc: 'recenterAtUserLoc'
      },
      requestGasButtonContainer: {
        initRequestGasForm: 'initRequestGasForm'
      },
      requestForm: {
        backToMap: 'backToMapFromRequestForm',
        sendRequest: 'sendRequest'
      },
      requestConfirmationForm: {
        backToRequestForm: 'backToRequestForm',
        confirmOrder: 'confirmOrder'
      },
      feedback: {
        sendFeedback: 'sendFeedback'
      },
      invite: {
        sendInvites: 'sendInvites'
      }
    }
  },
  mapInitiallyCenteredYet: false,
  mapInited: false,
  courierPingIntervalRef: null,
  launch: function() {
    this.callParent(arguments);
    this.gpsIntervalRef = setInterval(Ext.bind(this.updateLatlng, this), 10000);
    this.updateLatlng();
    setTimeout(Ext.bind(this.updateLatlng, this), 2000);
    setTimeout(Ext.bind(this.updateLatlng, this), 5000);
    return navigator.splashscreen.hide();
  },
  setUpPushNotifications: function() {
    if (Ext.os.name === "iOS") {
      return window.plugins.pushNotification.register(Ext.bind(this.registerDeviceForPushNotifications, this), (function(error) {
        return alert("error: " + error);
      }), {
        "badge": "true",
        "sound": "true",
        "alert": "true",
        "ecb": "onNotificationAPN"
      });
    } else {
      return window.plugins.pushNotification.register((function(result) {
        return alert("success: " + result);
      }), (function(error) {
        return alert("error: " + error);
      }), {
        "senderID": "replace_with_sender_id",
        "ecb": "onNotification"
      });
    }
  },
  registerDeviceForPushNotifications: function(cred) {
    return Ext.Ajax.request({
      url: "" + util.WEB_SERVICE_BASE_URL + "user/add-sns",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken'],
        cred: cred,
        push_platform: "apns"
      }),
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000,
      method: 'POST',
      scope: this,
      success: function(response_obj) {
        var response;
        response = Ext.JSON.decode(response_obj.responseText);
        if (response.success) {
          return localStorage['purpleUserHasPushNotificationsSetUp'] = "true";
        } else {
          return navigator.notification.alert(response.message, (function() {}), "Error");
        }
      },
      failure: function(response_obj) {
        return console.log(response_obj);
      }
    });
  },
  updateLatlng: function() {
    var _ref,
      _this = this;
    if ((_ref = this.updateLatlngBusy) == null) {
      this.updateLatlngBusy = false;
    }
    if (!this.updateLatlngBusy) {
      this.updateLatlngBusy = true;
      return navigator.geolocation.getCurrentPosition((function(position) {
        _this.updateLatlngBusy = false;
        _this.lat = position.coords.latitude;
        _this.lng = position.coords.longitude;
        if (!_this.mapInitiallyCenteredYet && _this.mapInited) {
          _this.mapInitiallyCenteredYet = true;
          return _this.recenterAtUserLoc();
        }
      }), (function() {
        return _this.updateLatlngBusy = false;
      }), {
        maximumAge: 0,
        enableHighAccuracy: true
      });
    }
  },
  initGeocoder: function() {
    this.geocoder = new google.maps.Geocoder();
    this.placesService = new google.maps.places.PlacesService(this.getMap().getMap());
    return this.mapInited = true;
  },
  adjustDeliveryLocByLatLng: function() {
    var center;
    center = this.getMap().getMap().getCenter();
    this.deliveryLocLat = center.lat();
    this.deliveryLocLng = center.lng();
    return this.updateDeliveryLocAddressByLatLng(this.deliveryLocLat, this.deliveryLocLng);
  },
  updateDeliveryLocAddressByLatLng: function(lat, lng) {
    var latlng, _ref,
      _this = this;
    latlng = new google.maps.LatLng(lat, lng);
    return (_ref = this.geocoder) != null ? _ref.geocode({
      'latLng': latlng
    }, function(results, status) {
      var addressComponents, c, streetAddress, t, _i, _len, _ref1, _results;
      if (status === google.maps.GeocoderStatus.OK) {
        if (((_ref1 = results[0]) != null ? _ref1['address_components'] : void 0) != null) {
          addressComponents = results[0]['address_components'];
          streetAddress = "" + addressComponents[0]['short_name'] + " " + addressComponents[1]['short_name'];
          _this.getRequestAddressField().setValue(streetAddress);
          _results = [];
          for (_i = 0, _len = addressComponents.length; _i < _len; _i++) {
            c = addressComponents[_i];
            _results.push((function() {
              var _j, _len1, _ref2, _results1;
              _ref2 = c.types;
              _results1 = [];
              for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
                t = _ref2[_j];
                if (t === "postal_code") {
                  _results1.push(this.deliveryAddressZipCode = c['short_name']);
                } else {
                  _results1.push(void 0);
                }
              }
              return _results1;
            }).call(_this));
          }
          return _results;
        }
      }
    }) : void 0;
  },
  mapMode: function() {
    this.getAutocompleteList().hide();
    this.getBackToMapButton().hide();
    this.getMap().show();
    this.getSpacerBetweenMapAndAddress().show();
    this.getRequestGasButtonContainer().show();
    return this.getRequestAddressField().disable();
  },
  recenterAtUserLoc: function() {
    return this.getMap().getMap().setCenter(new google.maps.LatLng(this.lat, this.lng));
  },
  addressInputMode: function() {
    this.getMap().hide();
    this.getSpacerBetweenMapAndAddress().hide();
    this.getRequestGasButtonContainer().hide();
    this.getAutocompleteList().show();
    this.getBackToMapButton().show();
    this.getRequestAddressField().enable();
    return this.getRequestAddressField().focus();
  },
  generateSuggestions: function() {
    var query, suggestions;
    query = this.getRequestAddressField().getValue();
    suggestions = new Array();
    return Ext.Ajax.request({
      url: "https://maps.googleapis.com/maps/api/place/autocomplete/json?types=establishment|geocode&radius=100&location=" + this.lat + "," + this.lng + "&sensor=true&key=AIzaSyA0p8k_hdb6m-xvAOosuYQnkDwjsn8NjFg",
      params: {
        'input': query
      },
      timeout: 30000,
      method: 'GET',
      scope: this,
      success: function(response) {
        var isAddress, locationName, p, resp, _i, _len, _ref, _ref1;
        resp = Ext.JSON.decode(response.responseText);
        if (resp.status === 'OK') {
          _ref = resp.predictions;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            p = _ref[_i];
            isAddress = p.terms[0].value === "" + parseInt(p.terms[0].value);
            locationName = isAddress ? p.terms[0].value + " " + ((_ref1 = p.terms[1]) != null ? _ref1.value : void 0) : p.terms[0].value;
            suggestions.push({
              'locationName': locationName,
              'locationVicinity': p.description.replace(locationName + ', ', ''),
              'locationLat': '0',
              'locationLng': '0',
              'placeId': p.place_id
            });
          }
          return this.getAutocompleteList().getStore().setData(suggestions);
        }
      }
    });
  },
  updateDeliveryLocAddressByLocArray: function(loc) {
    var _this = this;
    this.getRequestAddressField().setValue(loc['locationName']);
    this.mapMode();
    this.deliveryLocLat = 0;
    this.deliveryLocLng = 0;
    return this.placesService.getDetails({
      placeId: loc['placeId']
    }, function(place, status) {
      var c, latlng, t, _i, _j, _len, _len1, _ref, _ref1;
      if (status === google.maps.places.PlacesServiceStatus.OK) {
        latlng = place.geometry.location;
        _ref = place.address_components;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _ref1 = c.types;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            t = _ref1[_j];
            if (t === "postal_code") {
              _this.deliveryAddressZipCode = c['short_name'];
            }
          }
        }
        _this.deliveryLocLat = latlng.lat();
        _this.deliveryLocLng = latlng.lng();
        _this.getMap().getMap().setCenter(latlng);
        return _this.getMap().getMap().setZoom(17);
      }
    });
  },
  initRequestGasForm: function() {
    var deliveryLocName;
    deliveryLocName = this.getRequestAddressField().getValue();
    if (deliveryLocName === this.getRequestAddressField().getInitialConfig().value) {
      return;
    }
    if (!(util.ctl('Account').isUserLoggedIn() && util.ctl('Account').isCompleteAccount())) {
      return this.getMainContainer().getItems().getAt(0).select(1, false, false);
    } else {
      Ext.Viewport.setMasked({
        xtype: 'loadmask',
        message: ''
      });
      return Ext.Ajax.request({
        url: "" + util.WEB_SERVICE_BASE_URL + "dispatch/availability",
        params: Ext.JSON.encode({
          version: util.VERSION_NUMBER,
          user_id: localStorage['purpleUserId'],
          token: localStorage['purpleToken'],
          lat: this.deliveryLocLat,
          lng: this.deliveryLocLng,
          zip_code: this.deliveryAddressZipCode
        }),
        headers: {
          'Content-Type': 'application/json'
        },
        timeout: 30000,
        method: 'POST',
        scope: this,
        success: function(response_obj) {
          var response, totalGallons, totalNumOfTimeOptions;
          Ext.Viewport.setMasked(false);
          response = Ext.JSON.decode(response_obj.responseText);
          if (response.success) {
            totalGallons = response.availability.reduce(function(a, b) {
              return a.gallons + b.gallons;
            });
            totalNumOfTimeOptions = response.availability.reduce(function(a, b) {
              return a.time.count + b.time.count;
            });
            if (totalGallons < util.MINIMUM_GALLONS || totalNumOfTimeOptions === 0) {
              return navigator.notification.alert("Sorry, we are unable to deliver gas to your location at this time.", (function() {}), "Unavailable");
            } else {
              this.getRequestGasTabContainer().setActiveItem(Ext.create('Purple.view.RequestForm', {
                availability: response.availability
              }));
              return this.getRequestForm().setValues({
                lat: this.deliveryLocLat,
                lng: this.deliveryLocLng,
                address_street: deliveryLocName,
                address_zip: this.deliveryAddressZipCode
              });
            }
          } else {
            return navigator.notification.alert(response.message, (function() {}), "Error");
          }
        },
        failure: function(response_obj) {
          Ext.Viewport.setMasked(false);
          return console.log(response_obj);
        }
      });
    }
  },
  backToMapFromRequestForm: function() {
    return this.getRequestGasTabContainer().remove(this.getRequestForm(), true);
  },
  backToRequestForm: function() {
    this.getRequestGasTabContainer().setActiveItem(this.getRequestForm());
    return this.getRequestGasTabContainer().remove(this.getRequestConfirmationForm(), true);
  },
  sendRequest: function() {
    var a, appropriateAvailability, availability, gasPrice, gasType, serviceFee, v, vals, _i, _j, _len, _len1, _ref;
    this.getRequestGasTabContainer().setActiveItem(Ext.create('Purple.view.RequestConfirmationForm'));
    vals = this.getRequestForm().getValues();
    availability = this.getRequestForm().config.availability;
    gasType = util.ctl('Vehicles').getVehicleById(vals['vehicle']).gas_type;
    for (_i = 0, _len = availability.length; _i < _len; _i++) {
      a = availability[_i];
      if (a['octane'] === gasType) {
        appropriateAvailability = a;
        break;
      }
    }
    gasPrice = appropriateAvailability.price_per_gallon;
    serviceFee = (function() {
      switch (vals['time']) {
        case '< 1 hr':
          return appropriateAvailability.service_fee[0];
        case '< 3 hr':
          return appropriateAvailability.service_fee[1];
      }
    })();
    vals['gas_price'] = "" + util.centsToDollars(gasPrice);
    vals['service_fee'] = "" + util.centsToDollars(serviceFee);
    vals['total_price'] = "" + util.centsToDollars(parseFloat(gasPrice) * parseFloat(vals['gallons']) + parseFloat(serviceFee));
    vals['display_time'] = (function() {
      switch (vals['time']) {
        case '< 1 hr':
          return 'within 1 hour';
        case '< 3 hr':
          return 'within 3 hours';
      }
    })();
    vals['vehicle_id'] = vals['vehicle'];
    _ref = util.ctl('Vehicles').vehicles;
    for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
      v = _ref[_j];
      if (v['id'] === vals['vehicle_id']) {
        vals['vehicle'] = "" + v.year + " " + v.make + " " + v.model;
        break;
      }
    }
    this.getRequestConfirmationForm().setValues(vals);
    if (vals['special_instructions'] === '') {
      Ext.ComponentQuery.query('#specialInstructionsConfirmationLabel')[0].hide();
      Ext.ComponentQuery.query('#specialInstructionsConfirmation')[0].hide();
      return Ext.ComponentQuery.query('#addressStreetConfirmation')[0].removeCls('bottom-margin');
    }
  },
  confirmOrder: function() {
    var pmCtl, vals;
    if (!util.ctl('Account').hasDefaultPaymentMethod()) {
      this.getMainContainer().getItems().getAt(0).select(2, false, false);
      pmCtl = util.ctl('PaymentMethods');
      if (!(pmCtl.getPaymentMethods() != null)) {
        pmCtl.accountPaymentMethodFieldTap();
      }
      if (pmCtl.getEditPaymentMethodForm() != null) {
        pmCtl.getAccountTabContainer().setActiveItem(pmCtl.getEditPaymentMethodForm());
      } else {
        pmCtl.showEditPaymentMethodForm();
      }
      return pmCtl.getEditPaymentMethodForm().config.saveChangesCallback = function() {
        pmCtl.backToAccount();
        return util.ctl('Menu').selectOption(0);
      };
    } else {
      vals = this.getRequestConfirmationForm().getValues();
      vals['gas_price'] = parseInt(vals['gas_price'].replace('$', '').replace('.', ''));
      vals['service_fee'] = parseInt(vals['service_fee'].replace('$', '').replace('.', ''));
      vals['total_price'] = parseInt(vals['total_price'].replace('$', '').replace('.', ''));
      Ext.Viewport.setMasked({
        xtype: 'loadmask',
        message: ''
      });
      return Ext.Ajax.request({
        url: "" + util.WEB_SERVICE_BASE_URL + "orders/add",
        params: Ext.JSON.encode({
          version: util.VERSION_NUMBER,
          user_id: localStorage['purpleUserId'],
          token: localStorage['purpleToken'],
          order: vals
        }),
        headers: {
          'Content-Type': 'application/json'
        },
        timeout: 30000,
        method: 'POST',
        scope: this,
        success: function(response_obj) {
          var response;
          Ext.Viewport.setMasked(false);
          response = Ext.JSON.decode(response_obj.responseText);
          if (response.success) {
            util.ctl('Menu').selectOption(3);
            util.ctl('Orders').loadOrdersList(true);
            this.getRequestGasTabContainer().setActiveItem(this.getMapForm());
            this.getRequestGasTabContainer().remove(this.getRequestConfirmationForm(), true);
            this.getRequestGasTabContainer().remove(this.getRequestForm(), true);
            if (!util.ctl('Account').hasPushNotificationsSetup()) {
              return this.setUpPushNotifications();
            }
          } else {
            return navigator.notification.alert(response.message, (function() {}), "Error");
          }
        },
        failure: function(response_obj) {
          var response;
          Ext.Viewport.setMasked(false);
          response = Ext.JSON.decode(response_obj.responseText);
          return console.log(response);
        }
      });
    }
  },
  sendFeedback: function() {
    var params;
    params = {
      version: util.VERSION_NUMBER,
      text: this.getFeedbackTextField().getValue()
    };
    if (util.ctl('Account').isUserLoggedIn()) {
      params['user_id'] = localStorage['purpleUserId'];
      params['token'] = localStorage['purpleToken'];
    }
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: "" + util.WEB_SERVICE_BASE_URL + "feedback/send",
      params: Ext.JSON.encode(params),
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000,
      method: 'POST',
      scope: this,
      success: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        if (response.success) {
          this.getFeedbackTextField().setValue('');
          return util.flashComponent(this.getFeedbackThankYouMessage());
        } else {
          return navigator.notification.alert(response.message, (function() {}), "Error");
        }
      },
      failure: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        return console.log(response);
      }
    });
  },
  sendInvites: function() {
    var params;
    params = {
      version: util.VERSION_NUMBER,
      email: this.getInviteTextField().getValue()
    };
    if (util.ctl('Account').isUserLoggedIn()) {
      params['user_id'] = localStorage['purpleUserId'];
      params['token'] = localStorage['purpleToken'];
    }
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: "" + util.WEB_SERVICE_BASE_URL + "invite/send",
      params: Ext.JSON.encode(params),
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000,
      method: 'POST',
      scope: this,
      success: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        if (response.success) {
          this.getInviteTextField().setValue('');
          return util.flashComponent(this.getInviteThankYouMessage());
        } else {
          return navigator.notification.alert(response.message, (function() {}), "Error");
        }
      },
      failure: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        return console.log(response);
      }
    });
  },
  initCourierPing: function() {
    var _ref;
    if ((_ref = window.plugin) != null) {
      _ref.backgroundMode.enable();
    }
    return this.courierPingIntervalRef = setInterval(Ext.bind(this.courierPing, this), 10000);
  },
  killCourierPing: function() {
    if (this.courierPingIntervalRef != null) {
      return clearInterval(this.courierPingIntervalRef);
    }
  },
  courierPing: function() {
    var _ref;
    if ((_ref = this.errorCount) == null) {
      this.errorCount = 0;
    }
    return Ext.Ajax.request({
      url: "" + util.WEB_SERVICE_BASE_URL + "courier/ping",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken'],
        lat: this.lat,
        lng: this.lng,
        gallons: {
          87: localStorage['purpleCourierGallons87'],
          91: localStorage['purpleCourierGallons91']
        }
      }),
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000,
      method: 'POST',
      scope: this,
      success: function(response_obj) {
        var response;
        response = Ext.JSON.decode(response_obj.responseText);
        if (!response.success) {
          this.errorCount++;
          if (this.errorCount > 10) {
            return navigator.notification.alert("Unable to ping dispatch center.", (function() {}), "Error");
          }
        }
      },
      failure: function(response_obj) {
        Ext.Viewport.setMasked(false);
        this.errorCount++;
        if (this.errorCount > 10) {
          return navigator.notification.alert("Unable to ping dispatch center. Error #2.", (function() {}), "Error");
        }
      }
    });
  }
});
