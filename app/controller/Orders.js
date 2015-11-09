Ext.define('Purple.controller.Orders', {
  extend: 'Ext.app.Controller',
  requires: ['Purple.view.Order'],
  config: {
    refs: {
      mainContainer: 'maincontainer',
      topToolbar: 'toptoolbar',
      ordersTabContainer: '#ordersTabContainer',
      orders: 'orders',
      ordersList: '[ctype=ordersList]',
      order: 'order',
      orderSpecialInstructionsLabel: '[ctype=orderSpecialInstructionsLabel]',
      orderSpecialInstructions: '[ctype=orderSpecialInstructions]',
      orderAddressStreet: '[ctype=orderAddressStreet]',
      orderTimePlaced: '[ctype=orderTimePlaced]',
      orderTimeDeadline: '[ctype=orderTimeDeadline]',
      orderDisplayTime: '[ctype=orderDisplayTime]',
      orderVehicle: '[ctype=orderVehicle]',
      orderGasPrice: '[ctype=orderGasPrice]',
      orderGallons: '[ctype=orderGallons]',
      orderGasType: '[ctype=orderGasType]',
      orderHorizontalRuleAboveVehicle: '[ctype=orderHorizontalRuleAboveVehicle]',
      orderVehicleMake: '[ctype=orderVehicleMake]',
      orderVehicleModel: '[ctype=orderVehicleModel]',
      orderVehicleYear: '[ctype=orderVehicleYear]',
      orderVehicleColor: '[ctype=orderVehicleColor]',
      orderVehicleLicensePlate: '[ctype=orderVehicleLicensePlate]',
      orderVehiclePhoto: '[ctype=orderVehiclePhoto]',
      orderCustomerName: '[ctype=orderCustomerName]',
      orderCustomerPhone: '[ctype=orderCustomerPhone]',
      orderServiceFee: '[ctype=orderServiceFee]',
      orderTotalPrice: '[ctype=orderTotalPrice]',
      orderHorizontalRuleAboveCustomerInfo: '[ctype=orderHorizontalRuleAboveCustomerInfo]',
      orderRating: '[ctype=orderRating]',
      textRating: '[ctype=textRating]',
      sendRatingButtonContainer: '[ctype=sendRatingButtonContainer]',
      nextStatusButtonContainer: '[ctype=nextStatusButtonContainer]'
    },
    control: {
      orders: {
        viewOrder: 'viewOrder',
        loadOrdersList: 'loadOrdersList'
      },
      order: {
        backToOrders: 'backToOrders',
        cancelOrder: 'askToCancelOrder',
        sendRating: 'sendRating',
        nextStatus: 'askToNextStatus'
      },
      orderRating: {
        change: 'orderRatingChange'
      }
    }
  },
  orders: null,
  launch: function() {
    return this.callParent(arguments);
  },
  getOrderById: function(id) {
    var i, len, o, order, ref;
    ref = this.orders;
    for (i = 0, len = ref.length; i < len; i++) {
      o = ref[i];
      if (o['id'] === orderId) {
        order = o;
        break;
      }
    }
    return order;
  },
  viewOrder: function(orderId) {
    var c, diffHours, diffMinutes, i, j, len, len1, o, order, ref, ref1, v;
    ref = this.orders;
    for (i = 0, len = ref.length; i < len; i++) {
      o = ref[i];
      if (o['id'] === orderId) {
        order = o;
        break;
      }
    }
    this.getOrdersTabContainer().setActiveItem(Ext.create('Purple.view.Order', {
      orderId: orderId,
      status: order['status']
    }));
    util.ctl('Menu').pushOntoBackButton((function(_this) {
      return function() {
        return _this.backToOrders();
      };
    })(this));
    this.getOrder().addCls("status-" + order['status']);
    if (order['status'] === 'complete') {
      this.getOrderRating().show();
    }
    order['display_status'] = (function() {
      if (util.ctl('Account').isCourier()) {
        return order['status'];
      } else {
        switch (order['status']) {
          case 'unassigned':
            return 'Accepted';
          default:
            return order['status'];
        }
      }
    })();
    order['time_order_placed'] = Ext.util.Format.date(new Date(order['target_time_start'] * 1000), "g:i a");
    order['time_deadline'] = Ext.util.Format.date(new Date(order['target_time_end'] * 1000), "g:i a");
    diffMinutes = Math.floor((order['target_time_end'] - order['target_time_start']) / 60);
    if (diffMinutes < 60) {
      order['display_time'] = "within " + diffMinutes + " minutes";
    } else {
      diffHours = Math.round(diffMinutes / 60);
      order['display_time'] = "within " + diffHours + " hour" + (diffHours === 1 ? '' : 's');
    }
    ref1 = util.ctl('Vehicles').vehicles;
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      v = ref1[j];
      if (v['id'] === order['vehicle_id']) {
        order['vehicle'] = v.year + " " + v.make + " " + v.model;
        break;
      }
    }
    if (util.ctl('Account').isCourier()) {
      v = order['vehicle'];
      order['gas_type'] = v['gas_type'];
      order['vehicle_make'] = v['make'];
      order['vehicle_model'] = v['model'];
      order['vehicle_year'] = v['year'];
      order['vehicle_color'] = v['color'];
      order['vehicle_license_plate'] = v['license_plate'];
      order['vehicle_photo'] = v['photo'];
      c = order['customer'];
      order['customer_name'] = c['name'];
      order['customer_phone'] = c['phone_number'];
    }
    order['gas_price_display'] = util.centsToDollars(order['gas_price']);
    order['service_fee_display'] = util.centsToDollars(order['service_fee']);
    order['total_price_display'] = util.centsToDollars(order['total_price']);
    this.getOrder().setValues(order);
    if (order['special_instructions'] === '') {
      this.getOrderSpecialInstructionsLabel().hide();
      this.getOrderSpecialInstructions().hide();
      this.getOrderAddressStreet().removeCls('bottom-margin');
    }
    if (util.ctl('Account').isCourier()) {
      this.getOrderTimePlaced().hide();
      this.getOrderDisplayTime().hide();
      this.getOrderVehicle().hide();
      this.getOrderGasPrice().hide();
      this.getOrderServiceFee().hide();
      this.getOrderTotalPrice().hide();
      this.getOrderRating().hide();
      this.getOrderTimeDeadline().show();
      this.getOrderHorizontalRuleAboveVehicle().show();
      this.getOrderVehicleMake().show();
      this.getOrderVehicleModel().show();
      this.getOrderVehicleYear().show();
      this.getOrderVehicleColor().show();
      this.getOrderVehicleLicensePlate().show();
      this.getOrderHorizontalRuleAboveCustomerInfo().show();
      this.getOrderCustomerName().show();
      this.getOrderCustomerPhone().show();
      this.getOrderGasType().show();
      switch (order['status']) {
        case "unassigned":
          this.getNextStatusButtonContainer().getAt(0).setText("Accept Order");
          this.getNextStatusButtonContainer().show();
          break;
        case "accepted":
          this.getNextStatusButtonContainer().getAt(0).setText("Start Route");
          this.getNextStatusButtonContainer().show();
          break;
        case "enroute":
          this.getNextStatusButtonContainer().getAt(0).setText("Begin Servicing");
          this.getNextStatusButtonContainer().show();
          break;
        case "servicing":
          this.getNextStatusButtonContainer().getAt(0).setText("Complete Order");
          this.getNextStatusButtonContainer().show();
      }
      this.getOrderAddressStreet().addCls('click-to-edit');
      this.getOrderAddressStreet().element.on('tap', (function(_this) {
        return function() {
          return window.location.href = "comgooglemaps://?daddr=" + order.lat + "," + order.lng + "&directionsmode=driving";
        };
      })(this));
      this.getOrderCustomerPhone().addCls('click-to-edit');
      this.getOrderCustomerPhone().element.on('tap', (function(_this) {
        return function() {
          return window.location.href = "tel://" + order['customer_phone'];
        };
      })(this));
      if ((order["vehicle_photo"] != null) && order["vehicle_photo"] !== '') {
        this.getOrderVehiclePhoto().show();
        return this.getOrderVehiclePhoto().element.dom.style.cssText = "background-color: transparent;\nbackground-size: cover;\nbackground-repeat: no-repeat;\nbackground-position: center;\nheight: 300px;\nwidth: 100%;\nbackground-image: url('" + order["vehicle_photo"] + "') !important;";
      }
    }
  },
  backToOrders: function() {
    var ref;
    return (ref = this.getOrdersTabContainer()) != null ? ref.remove(this.getOrder(), true) : void 0;
  },
  loadOrdersList: function(forceUpdate, callback) {
    if (forceUpdate == null) {
      forceUpdate = false;
    }
    if (callback == null) {
      callback = null;
    }
    if ((this.orders != null) && !forceUpdate) {
      return this.renderOrdersList(this.orders);
    } else {
      Ext.Viewport.setMasked({
        xtype: 'loadmask',
        message: ''
      });
      return Ext.Ajax.request({
        url: util.WEB_SERVICE_BASE_URL + "user/details",
        params: Ext.JSON.encode({
          version: util.VERSION_NUMBER,
          user_id: localStorage['purpleUserId'],
          token: localStorage['purpleToken'],
          os: Ext.os.name
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
            this.orders = response.orders;
            util.ctl('Vehicles').vehicles = response.vehicles;
            util.ctl('Vehicles').loadVehiclesList();
            this.renderOrdersList(this.orders);
            return typeof callback === "function" ? callback() : void 0;
          } else {
            return navigator.notification.alert(response.message, (function() {}), "Error");
          }
        },
        failure: function(response_obj) {
          var response;
          Ext.Viewport.setMasked(false);
          if (util.ctl('Account').isCourier()) {
            navigator.notification.alert("Slow or no internet connection.", (function() {}), "Error");
          }
          response = Ext.JSON.decode(response_obj.responseText);
          return console.log(response);
        }
      });
    }
  },
  renderOrdersList: function(orders) {
    var cls, dateDisplay, i, isLate, len, list, o, results, v;
    list = this.getOrdersList();
    if (list == null) {
      return;
    }
    list.removeAll(true, true);
    results = [];
    for (i = 0, len = orders.length; i < len; i++) {
      o = orders[i];
      if (util.ctl('Account').isCourier()) {
        v = o['vehicle'];
      } else {
        v = util.ctl('Vehicles').getVehicleById(o.vehicle_id);
      }
      if (v == null) {
        v = {
          id: o.vehicle_id,
          user_id: localStorage['purpleUserId'],
          year: "Vehicle Deleted",
          timestamp_created: "1970-01-01T00:00:00Z",
          color: "",
          gas_type: "",
          license_plate: "",
          make: "",
          model: ""
        };
      }
      cls = ['bottom-margin', 'order-list-item'];
      if (o.status === 'unassigned' || o.status === 'assigned' || o.status === 'accepted' || o.status === 'enroute' || o.status === 'servicing') {
        cls.push('highlighted');
      }
      if (util.ctl('Account').isCourier()) {
        isLate = o.status !== "complete" && o.status !== "cancelled" && (new Date(o.target_time_end * 1000)) < (new Date());
        dateDisplay = "<span style=\"" + (isLate ? "color: #f00;" : "") + "\">\n  " + (Ext.util.Format.date(new Date(o.target_time_end * 1000), "n/j g:i a")) + "\n</span>";
      } else {
        dateDisplay = Ext.util.Format.date(new Date(o.target_time_start * 1000), "F jS");
      }
      results.push(list.add({
        xtype: 'textfield',
        id: "oid_" + o.id,
        flex: 0,
        label: dateDisplay + "\n<br /><span class=\"subtext\">" + v.year + " " + v.make + " " + v.model + "</span>\n<div class=\"status-square\">\n  <div class=\"fill\">\n    <svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" width=\"60px\" height=\"60px\" viewBox=\"0 0 60 60\" enable-background=\"new 0 0 60 60\" xml:space=\"preserve\">\n      <path fill=\"#04ACFF\" id=\"waveShape\" d=\"M300,300V2.5c0,0-0.6-0.1-1.1-0.1c0,0-25.5-2.3-40.5-2.4c-15,0-40.6,2.4-40.6,2.4\nc-12.3,1.1-30.3,1.8-31.9,1.9c-2-0.1-19.7-0.8-32-1.9c0,0-25.8-2.3-40.8-2.4c-15,0-40.8,2.4-40.8,2.4c-12.3,1.1-30.4,1.8-32,1.9\nc-2-0.1-20-0.8-32.2-1.9c0,0-3.1-0.3-8.1-0.7V300H300z\"/>\n    </svg>\n  </div>\n</div>",
        labelWidth: '100%',
        cls: cls,
        disabled: true,
        listeners: {
          painted: ((function(_this) {
            return function(o) {
              return function(field) {
                return field.addCls("status-" + o.status);
              };
            };
          })(this))(o),
          initialize: (function(_this) {
            return function(field) {
              return field.element.on('tap', function() {
                var oid;
                oid = field.getId().split('_')[1];
                return _this.viewOrder(oid);
              });
            };
          })(this)
        }
      }));
    }
    return results;
  },
  askToCancelOrder: function(id) {
    return navigator.notification.confirm("", ((function(_this) {
      return function(index) {
        switch (index) {
          case 1:
            return _this.cancelOrder(id);
        }
      };
    })(this)), "Are you sure you want to cancel this order?", ["Yes", "No"]);
  },
  cancelOrder: function(id) {
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: util.WEB_SERVICE_BASE_URL + "orders/cancel",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken'],
        order_id: id
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
          this.orders = response.orders;
          this.backToOrders();
          util.ctl('Menu').popOffBackButtonWithoutAction();
          return this.renderOrdersList(this.orders);
        } else {
          return navigator.notification.alert(response.message, (function() {}), "Error");
        }
      },
      failure: function(response_obj) {
        Ext.Viewport.setMasked(false);
        console.log(response_obj);
        return navigator.notification.alert("Connection error. Please try again.", (function() {}), "Error");
      }
    });
  },
  orderRatingChange: function(field, value) {
    this.getTextRating().show();
    return this.getSendRatingButtonContainer().show();
  },
  sendRating: function() {
    var id, values;
    values = this.getOrder().getValues();
    id = this.getOrder().config.orderId;
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: util.WEB_SERVICE_BASE_URL + "orders/rate",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken'],
        order_id: id,
        rating: {
          number_rating: values['number_rating'],
          text_rating: values['text_rating']
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
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        if (response.success) {
          this.orders = response.orders;
          this.backToOrders();
          util.ctl('Menu').popOffBackButtonWithoutAction();
          return this.renderOrdersList(this.orders);
        } else {
          return navigator.notification.alert(response.message, (function() {}), "Error");
        }
      },
      failure: function(response_obj) {
        Ext.Viewport.setMasked(false);
        console.log(response_obj);
        return navigator.notification.alert("Connection error. Please try again.", (function() {}), "Error");
      }
    });
  },
  askToNextStatus: function() {
    var currentStatus, nextStatus, values;
    values = this.getOrder().getValues();
    currentStatus = values['status'];
    nextStatus = util.NEXT_STATUS_MAP[currentStatus];
    return navigator.notification.confirm("", ((function(_this) {
      return function(index) {
        switch (index) {
          case 1:
            return _this.nextStatus();
        }
      };
    })(this)), ((function() {
      switch (nextStatus) {
        case "assigned":
        case "accepted":
          return "Are you sure you want to accept this order? (cannot be undone)";
        default:
          return "Are you sure you want to mark this order as " + nextStatus + "? (cannot be undone)";
      }
    })()), ["Yes", "No"]);
  },
  nextStatus: function() {
    var currentStatus, id, values;
    values = this.getOrder().getValues();
    currentStatus = values['status'];
    id = this.getOrder().config.orderId;
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: util.WEB_SERVICE_BASE_URL + "orders/update-status-by-courier",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken'],
        order_id: id,
        status: util.NEXT_STATUS_MAP[currentStatus]
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
          this.orders = response.orders;
          this.backToOrders();
          util.ctl('Menu').popOffBackButtonWithoutAction();
          return this.renderOrdersList(this.orders);
        } else {
          return navigator.notification.alert(response.message, (function() {}), "Error");
        }
      },
      failure: function(response_obj) {
        Ext.Viewport.setMasked(false);
        console.log(response_obj);
        return navigator.notification.alert("Connection error. Please go back to Orders page and pull down to refresh. Do not press this button again until you have the updated status on the Orders page.", (function() {}), "Error");
      }
    });
  }
});
