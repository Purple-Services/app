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
      gasPriceMapDisplay: '#gasPriceMapDisplay',
      requestAddressField: '#requestAddressField',
      requestGasButtonContainer: '#requestGasButtonContainer',
      autocompleteList: '#autocompleteList',
      requestForm: 'requestform',
      requestConfirmationForm: 'requestconfirmationform',
      feedback: 'feedback',
      feedbackTextField: '[ctype=feedbackTextField]',
      feedbackThankYouMessage: '[ctype=feedbackThankYouMessage]',
      invite: 'invite',
      inviteTextField: '[ctype=inviteTextField]',
      inviteThankYouMessage: '[ctype=inviteThankYouMessage]',
      freeGasField: '#freeGasField',
      discountField: '#discountField',
      couponCodeField: '#couponCodeField',
      totalPriceField: '#totalPriceField'
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
    var ref;
    this.callParent(arguments);
    this.gpsIntervalRef = setInterval(Ext.bind(this.updateLatlng, this), 5000);
    if (typeof ga_storage !== "undefined" && ga_storage !== null) {
      ga_storage._enableSSL();
    }
    if (typeof ga_storage !== "undefined" && ga_storage !== null) {
      ga_storage._setAccount('UA-61762011-1');
    }
    if (typeof ga_storage !== "undefined" && ga_storage !== null) {
      ga_storage._setDomain('none');
    }
    if (typeof ga_storage !== "undefined" && ga_storage !== null) {
      ga_storage._trackEvent('main', 'App Launch', "Platform: " + Ext.os.name);
    }
    if ((ref = navigator.splashscreen) != null) {
      ref.hide();
    }
    if (util.ctl('Account').hasPushNotificationsSetup()) {
      return setTimeout(Ext.bind(this.setUpPushNotifications, this), 4000);
    }
  },
  setUpPushNotifications: function() {
    var ref, ref1, ref2, ref3;
    if (Ext.os.name === "iOS") {
      return (ref = window.plugins) != null ? (ref1 = ref.pushNotification) != null ? ref1.register(Ext.bind(this.registerDeviceForPushNotifications, this), (function(error) {
        return alert("error: " + error);
      }), {
        "badge": "true",
        "sound": "true",
        "alert": "true",
        "ecb": "onNotificationAPN"
      }) : void 0 : void 0;
    } else {
      return (ref2 = window.plugins) != null ? (ref3 = ref2.pushNotification) != null ? ref3.register((function(result) {}), (function(error) {
        return alert("error: " + error);
      }), {
        "senderID": util.GCM_SENDER_ID,
        "ecb": "onNotification"
      }) : void 0 : void 0;
    }
  },
  registerDeviceForPushNotifications: function(cred, pushPlatform) {
    if (pushPlatform == null) {
      pushPlatform = "apns";
    }
    return Ext.Ajax.request({
      url: util.WEB_SERVICE_BASE_URL + "user/add-sns",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken'],
        cred: cred,
        push_platform: pushPlatform
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
    var ref;
    if (this.updateLatlngBusy == null) {
      this.updateLatlngBusy = false;
    }
    if (!this.updateLatlngBusy) {
      this.updateLatlngBusy = true;
      return (ref = navigator.geolocation) != null ? ref.getCurrentPosition(((function(_this) {
        return function(position) {
          _this.updateLatlngBusy = false;
          _this.lat = position.coords.latitude;
          _this.lng = position.coords.longitude;
          if (!_this.mapInitiallyCenteredYet && _this.mapInited) {
            _this.mapInitiallyCenteredYet = true;
            return _this.recenterAtUserLoc();
          }
        };
      })(this)), ((function(_this) {
        return function() {
          return _this.updateLatlngBusy = false;
        };
      })(this)), {
        maximumAge: 0,
        enableHighAccuracy: true
      }) : void 0;
    }
  },
  initGeocoder: function() {
    this.updateLatlng();
    if ((typeof google !== "undefined" && google !== null) && (google.maps != null) && (this.getMap() != null)) {
      this.geocoder = new google.maps.Geocoder();
      this.placesService = new google.maps.places.PlacesService(this.getMap().getMap());
      return this.mapInited = true;
    } else {
      return navigator.notification.alert("Internet connection problem. Please try closing the app and restarting it.", (function() {}), "Connection Error");
    }
  },
  adjustDeliveryLocByLatLng: function() {
    var center;
    center = this.getMap().getMap().getCenter();
    this.deliveryLocLat = center.lat();
    this.deliveryLocLng = center.lng();
    return this.updateDeliveryLocAddressByLatLng(this.deliveryLocLat, this.deliveryLocLng);
  },
  updateDeliveryLocAddressByLatLng: function(lat, lng) {
    var latlng, ref;
    latlng = new google.maps.LatLng(lat, lng);
    return (ref = this.geocoder) != null ? ref.geocode({
      'latLng': latlng
    }, (function(_this) {
      return function(results, status) {
        var addressComponents, c, i, j, len, len1, ref1, ref2, streetAddress, t;
        if (status === google.maps.GeocoderStatus.OK) {
          if (((ref1 = results[0]) != null ? ref1['address_components'] : void 0) != null) {
            addressComponents = results[0]['address_components'];
            streetAddress = addressComponents[0]['short_name'] + " " + addressComponents[1]['short_name'];
            _this.getRequestAddressField().setValue(streetAddress);
            for (i = 0, len = addressComponents.length; i < len; i++) {
              c = addressComponents[i];
              ref2 = c.types;
              for (j = 0, len1 = ref2.length; j < len1; j++) {
                t = ref2[j];
                if (t === "postal_code") {
                  _this.deliveryAddressZipCode = c['short_name'];
                }
              }
            }
            if (_this.busyGettingGasPrice == null) {
              _this.busyGettingGasPrice = false;
            }
            if (!_this.busyGettingGasPrice) {
              _this.busyGettingGasPrice = true;
              return Ext.Ajax.request({
                url: util.WEB_SERVICE_BASE_URL + "dispatch/gas-prices",
                params: Ext.JSON.encode({
                  version: util.VERSION_NUMBER,
                  zip_code: _this.deliveryAddressZipCode
                }),
                headers: {
                  'Content-Type': 'application/json'
                },
                timeout: 30000,
                method: 'POST',
                scope: _this,
                success: function(response_obj) {
                  var prices, response;
                  response = Ext.JSON.decode(response_obj.responseText);
                  if (response.success) {
                    prices = response.gas_prices;
                    Ext.get('gas-price-display-87').setText("$" + (util.centsToDollars(prices["87"])));
                    Ext.get('gas-price-display-91').setText("$" + (util.centsToDollars(prices["91"])));
                  }
                  return this.busyGettingGasPrice = false;
                },
                failure: function(response_obj) {
                  this.busyGettingGasPrice = false;
                  return console.log(response_obj);
                }
              });
            }
          }
        }
      };
    })(this)) : void 0;
  },
  mapMode: function() {
    if (this.getMap().isHidden()) {
      this.getAutocompleteList().hide();
      this.getMap().show();
      this.getSpacerBetweenMapAndAddress().show();
      this.getGasPriceMapDisplay().show();
      this.getRequestGasButtonContainer().show();
      return this.getRequestAddressField().disable();
    }
  },
  recenterAtUserLoc: function() {
    return this.getMap().getMap().setCenter(new google.maps.LatLng(this.lat, this.lng));
  },
  addressInputMode: function() {
    if (!this.getMap().isHidden()) {
      this.getMap().hide();
      this.getSpacerBetweenMapAndAddress().hide();
      this.getGasPriceMapDisplay().hide();
      this.getRequestGasButtonContainer().hide();
      this.getAutocompleteList().show();
      this.getRequestAddressField().enable();
      this.getRequestAddressField().focus();
      util.ctl('Menu').pushOntoBackButton((function(_this) {
        return function() {
          _this.recenterAtUserLoc();
          return _this.mapMode();
        };
      })(this));
      return ga_storage._trackEvent('ui', 'Address Text Input Mode');
    }
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
        var i, isAddress, len, locationName, p, ref, ref1, resp;
        resp = Ext.JSON.decode(response.responseText);
        if (resp.status === 'OK') {
          ref = resp.predictions;
          for (i = 0, len = ref.length; i < len; i++) {
            p = ref[i];
            isAddress = p.terms[0].value === "" + parseInt(p.terms[0].value);
            locationName = isAddress ? p.terms[0].value + " " + ((ref1 = p.terms[1]) != null ? ref1.value : void 0) : p.terms[0].value;
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
    this.getRequestAddressField().setValue(loc['locationName']);
    this.mapMode();
    util.ctl('Menu').clearBackButtonStack();
    this.deliveryLocLat = 0;
    this.deliveryLocLng = 0;
    return this.placesService.getDetails({
      placeId: loc['placeId']
    }, (function(_this) {
      return function(place, status) {
        var c, i, j, latlng, len, len1, ref, ref1, t;
        if (status === google.maps.places.PlacesServiceStatus.OK) {
          latlng = place.geometry.location;
          ref = place.address_components;
          for (i = 0, len = ref.length; i < len; i++) {
            c = ref[i];
            ref1 = c.types;
            for (j = 0, len1 = ref1.length; j < len1; j++) {
              t = ref1[j];
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
      };
    })(this));
  },
  initRequestGasForm: function() {
    var deliveryLocName;
    ga_storage._trackEvent('ui', 'Request Gas Button Pressed');
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
        url: util.WEB_SERVICE_BASE_URL + "dispatch/availability",
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
          var availabilities, response, totalGallons, totalNumOfTimeOptions;
          Ext.Viewport.setMasked(false);
          response = Ext.JSON.decode(response_obj.responseText);
          if (response.success) {
            localStorage['purpleUserReferralCode'] = response.user.referral_code;
            localStorage['purpleUserReferralGallons'] = "" + response.user.referral_gallons;
            availabilities = response.availabilities;
            totalGallons = availabilities.reduce(function(a, b) {
              return a.gallons + b.gallons;
            });
            totalNumOfTimeOptions = availabilities.reduce(function(a, b) {
              return Object.keys(a.times).length + Object.keys(b.times).length;
            });
            if (totalGallons < util.MINIMUM_GALLONS || totalNumOfTimeOptions === 0) {
              return navigator.notification.alert(response["unavailable-reason"], (function() {}), "Unavailable");
            } else {
              util.ctl('Menu').pushOntoBackButton((function(_this) {
                return function() {
                  return _this.backToMapFromRequestForm();
                };
              })(this));
              this.getRequestGasTabContainer().setActiveItem(Ext.create('Purple.view.RequestForm', {
                availabilities: availabilities
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
    var a, availabilities, availability, freeGallonsAvailable, gallonsToSubtract, gasPrice, gasType, i, j, len, len1, ref, serviceFee, v, vals;
    this.getRequestGasTabContainer().setActiveItem(Ext.create('Purple.view.RequestConfirmationForm'));
    util.ctl('Menu').pushOntoBackButton((function(_this) {
      return function() {
        return _this.backToRequestForm();
      };
    })(this));
    vals = this.getRequestForm().getValues();
    availabilities = this.getRequestForm().config.availabilities;
    gasType = util.ctl('Vehicles').getVehicleById(vals['vehicle']).gas_type;
    for (i = 0, len = availabilities.length; i < len; i++) {
      a = availabilities[i];
      if (a['octane'] === gasType) {
        availability = a;
        break;
      }
    }
    vals['gas_type'] = "" + availability.octane;
    gasPrice = availability.price_per_gallon;
    serviceFee = availability.times[vals['time']]['service_fee'];
    vals['gas_price'] = "" + util.centsToDollars(gasPrice);
    vals['gas_price_display'] = "$" + vals['gas_price'] + " x " + vals['gallons'];
    vals['service_fee'] = "" + util.centsToDollars(serviceFee);
    freeGallonsAvailable = parseInt(localStorage['purpleUserReferralGallons']);
    gallonsToSubtract = 0;
    if (freeGallonsAvailable === 0) {
      this.getFreeGasField().hide();
    } else {
      gallonsToSubtract = Math.min(vals['gallons'], freeGallonsAvailable);
      this.getFreeGasField().setValue("- $" + vals['gas_price'] + " x " + gallonsToSubtract);
    }
    this.unalteredTotalPrice = parseFloat(gasPrice) * (parseFloat(vals['gallons']) - gallonsToSubtract) + parseFloat(serviceFee);
    vals['total_price'] = "" + util.centsToDollars(this.unalteredTotalPrice);
    vals['display_time'] = availability.times[vals['time']]['text'];
    vals['vehicle_id'] = vals['vehicle'];
    ref = util.ctl('Vehicles').vehicles;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      v = ref[j];
      if (v['id'] === vals['vehicle_id']) {
        vals['vehicle'] = v.year + " " + v.make + " " + v.model;
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
  promptForCode: function() {
    return Ext.Msg.prompt('Enter Coupon Code', false, ((function(_this) {
      return function(buttonId, text) {
        if (buttonId === 'ok') {
          return _this.applyCode(text);
        }
      };
    })(this)));
  },
  applyCode: function(code) {
    var vals, vehicleId;
    vals = this.getRequestConfirmationForm().getValues();
    vehicleId = vals['vehicle_id'];
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: util.WEB_SERVICE_BASE_URL + "user/code",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken'],
        vehicle_id: vehicleId,
        code: code
      }),
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000,
      method: 'POST',
      scope: this,
      success: function(response_obj) {
        var response, totalPrice;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        if (response.success) {
          this.getDiscountField().setValue("- $" + util.centsToDollars(Math.abs(response.value)));
          this.getCouponCodeField().setValue(code);
          totalPrice = Math.max(this.unalteredTotalPrice + response.value, 0);
          return this.getTotalPriceField().setValue("" + util.centsToDollars(totalPrice));
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
  confirmOrder: function() {
    var pmCtl, vals;
    if (!util.ctl('Account').hasDefaultPaymentMethod()) {
      this.getMainContainer().getItems().getAt(0).select(2, false, false);
      pmCtl = util.ctl('PaymentMethods');
      if (pmCtl.getPaymentMethods() == null) {
        pmCtl.accountPaymentMethodFieldTap(true);
      }
      pmCtl.showEditPaymentMethodForm('new', true);
      util.ctl('Menu').pushOntoBackButton(function() {
        pmCtl.backToAccount();
        return util.ctl('Menu').selectOption(0);
      });
      return pmCtl.getEditPaymentMethodForm().config.saveChangesCallback = function() {
        util.ctl('Menu').popOffBackButtonWithoutAction();
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
        url: util.WEB_SERVICE_BASE_URL + "orders/add",
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
          var ref, response;
          Ext.Viewport.setMasked(false);
          response = Ext.JSON.decode(response_obj.responseText);
          if (response.success) {
            util.ctl('Menu').selectOption(3);
            util.ctl('Orders').loadOrdersList(true);
            this.getRequestGasTabContainer().setActiveItem(this.getMapForm());
            this.getRequestGasTabContainer().remove(this.getRequestConfirmationForm(), true);
            this.getRequestGasTabContainer().remove(this.getRequestForm(), true);
            util.ctl('Menu').clearBackButtonStack();
            navigator.notification.alert(response.message, (function() {}), (ref = response.message_title) != null ? ref : "Success");
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
      url: util.WEB_SERVICE_BASE_URL + "feedback/send",
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
      url: util.WEB_SERVICE_BASE_URL + "invite/send",
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
    var ref;
    if ((ref = window.plugin) != null) {
      ref.backgroundMode.enable();
    }
    return this.courierPingIntervalRef = setInterval(Ext.bind(this.courierPing, this), 10000);
  },
  killCourierPing: function() {
    if (this.courierPingIntervalRef != null) {
      return clearInterval(this.courierPingIntervalRef);
    }
  },
  courierPing: function() {
    if (this.errorCount == null) {
      this.errorCount = 0;
    }
    if (this.courierPingBusy == null) {
      this.courierPingBusy = false;
    }
    if (!this.courierPingBusy) {
      this.courierPingBusy = true;
      return Ext.Ajax.request({
        url: util.WEB_SERVICE_BASE_URL + "courier/ping",
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
          this.courierPingBusy = false;
          response = Ext.JSON.decode(response_obj.responseText);
          if (response.success) {
            if (this.disconnectedMessage != null) {
              clearTimeout(this.disconnectedMessage);
            }
            Ext.get(document.getElementsByTagName('body')[0]).removeCls('disconnected');
            return this.disconnectedMessage = setTimeout((function() {
              return Ext.get(document.getElementsByTagName('body')[0]).addCls('disconnected');
            }), 2 * 60 * 1000);
          } else {
            this.errorCount++;
            if (this.errorCount > 10) {
              this.errorCount = 0;
              return navigator.notification.alert("Unable to ping dispatch center. Web service problem, please notify Chris.", (function() {}), "Error");
            }
          }
        },
        failure: function(response_obj) {
          return this.courierPingBusy = false;
        }
      });
    }
  }
});
