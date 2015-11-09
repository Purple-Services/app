Ext.define('Purple.controller.PaymentMethods', {
  extend: 'Ext.app.Controller',
  requires: ['Purple.view.EditPaymentMethodForm'],
  config: {
    refs: {
      mainContainer: 'maincontainer',
      topToolbar: 'toptoolbar',
      accountTabContainer: '#accountTabContainer',
      accountForm: 'accountform',
      paymentMethods: 'paymentmethods',
      paymentMethodsList: '[ctype=paymentMethodsList]',
      editPaymentMethodForm: 'editpaymentmethodform',
      editPaymentMethodFormHeading: '[ctype=editPaymentMethodFormHeading]',
      backToPaymentMethodsButton: '[ctype=backToPaymentMethodsButton]',
      accountPaymentMethodField: '#accountPaymentMethodField'
    },
    control: {
      paymentMethods: {
        editPaymentMethod: 'showEditPaymentMethodForm',
        loadPaymentMethodsList: 'loadPaymentMethodsList',
        backToAccount: 'backToAccount'
      },
      editPaymentMethodForm: {
        backToPaymentMethods: 'backToPaymentMethods',
        saveChanges: 'saveChanges',
        deletePaymentMethod: 'deletePaymentMethod'
      },
      editPaymentMethodFormYear: {
        change: 'yearChanged'
      },
      editPaymentMethodFormMake: {
        change: 'makeChanged'
      },
      accountPaymentMethodField: {
        initialize: 'initAccountPaymentMethodField'
      }
    }
  },
  paymentMethods: null,
  launch: function() {
    return this.callParent(arguments);
  },
  getPaymentMethodById: function(id) {
    var i, len, paymentMethod, ref, v;
    ref = this.paymentMethods;
    for (i = 0, len = ref.length; i < len; i++) {
      v = ref[i];
      if (v['id'] === id) {
        paymentMethod = v;
        break;
      }
    }
    return paymentMethod;
  },
  showEditPaymentMethodForm: function(paymentMethodId, suppressBackButtonBehavior) {
    if (paymentMethodId == null) {
      paymentMethodId = 'new';
    }
    if (suppressBackButtonBehavior == null) {
      suppressBackButtonBehavior = false;
    }
    this.getAccountTabContainer().setActiveItem(Ext.create('Purple.view.EditPaymentMethodForm', {
      paymentMethodId: paymentMethodId
    }));
    if (!suppressBackButtonBehavior) {
      util.ctl('Menu').pushOntoBackButton((function(_this) {
        return function() {
          return _this.backToPaymentMethods();
        };
      })(this));
    }
    return this.getEditPaymentMethodFormHeading().setHtml(paymentMethodId === 'new' ? 'Add Card' : 'Edit Card');
  },
  backToPaymentMethods: function() {
    this.getAccountTabContainer().setActiveItem(this.getPaymentMethods());
    return this.getAccountTabContainer().remove(this.getEditPaymentMethodForm(), true);
  },
  backToAccount: function() {
    this.getAccountTabContainer().setActiveItem(this.getAccountForm());
    this.getAccountTabContainer().remove(this.getPaymentMethods(), true);
    if (this.getEditPaymentMethodForm() != null) {
      return this.getAccountTabContainer().remove(this.getEditPaymentMethodForm(), true);
    }
  },
  loadPaymentMethodsList: function() {
    if (this.paymentMethods != null) {
      return this.renderPaymentMethodsList(this.paymentMethods);
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
          var c, card, ref, response;
          Ext.Viewport.setMasked(false);
          response = Ext.JSON.decode(response_obj.responseText);
          if (response.success) {
            this.paymentMethods = response.cards;
            delete localStorage['purpleDefaultPaymentMethodId'];
            ref = response.cards;
            for (c in ref) {
              card = ref[c];
              if (card["default"]) {
                localStorage['purpleDefaultPaymentMethodId'] = card.id;
                localStorage['purpleDefaultPaymentMethodDisplayText'] = card.brand + " *" + card.last4;
              }
            }
            this.refreshAccountPaymentMethodField();
            util.ctl('Orders').orders = response.orders;
            util.ctl('Orders').loadOrdersList();
            util.ctl('Vehicles').vehicles = response.vehicles;
            util.ctl('Vehicles').loadVehiclesList();
            localStorage['purpleReferralReferredValue'] = response.system.referral_referred_value;
            localStorage['purpleReferralReferrerGallons'] = response.system.referral_referrer_gallons;
            return this.renderPaymentMethodsList(this.paymentMethods);
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
  renderPaymentMethodsList: function(paymentMethods) {
    var i, len, list, p, results;
    list = this.getPaymentMethodsList();
    if (list == null) {
      return;
    }
    list.removeAll(true, true);
    results = [];
    for (i = 0, len = paymentMethods.length; i < len; i++) {
      p = paymentMethods[i];
      results.push(list.add({
        xtype: 'textfield',
        id: "pmid_" + p.id,
        flex: 0,
        label: p.brand + " *" + p.last4,
        labelWidth: '100%',
        cls: ['bottom-margin', 'click-to-edit'],
        disabled: true,
        listeners: {
          initialize: (function(_this) {
            return function(field) {
              return field.element.on('tap', function() {
                var pmid;
                pmid = field.getId().substring(5);
                return navigator.notification.confirm("", (function(index) {
                  switch (index) {
                    case 1:
                      return _this.askToDeleteCard(pmid);
                    case 2:
                      return _this.makeDefault(pmid);
                  }
                }), p.brand + " *" + p.last4, ["Delete Card", "Make Default", "Cancel"]);
              });
            };
          })(this)
        }
      }));
    }
    return results;
  },
  askToDeleteCard: function(id) {
    return navigator.notification.confirm("", ((function(_this) {
      return function(index) {
        switch (index) {
          case 1:
            return _this.deleteCard(id);
        }
      };
    })(this)), "Are you sure you want to delete this card?", ["Delete Card", "Cancel"]);
  },
  deleteCard: function(id) {
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: util.WEB_SERVICE_BASE_URL + "user/edit",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken'],
        card: {
          id: id,
          action: 'delete'
        }
      }),
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000,
      method: 'POST',
      scope: this,
      success: function(response_obj) {
        var c, card, ref, response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        if (response.success) {
          this.paymentMethods = response.cards;
          delete localStorage['purpleDefaultPaymentMethodId'];
          ref = response.cards;
          for (c in ref) {
            card = ref[c];
            if (card["default"]) {
              localStorage['purpleDefaultPaymentMethodId'] = card.id;
              localStorage['purpleDefaultPaymentMethodDisplayText'] = card.brand + " *" + card.last4;
            }
          }
          this.refreshAccountPaymentMethodField();
          util.ctl('Vehicles').vehicles = response.vehicles;
          util.ctl('Orders').orders = response.orders;
          return this.renderPaymentMethodsList(this.paymentMethods);
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
  makeDefault: function(id) {
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: util.WEB_SERVICE_BASE_URL + "user/edit",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken'],
        card: {
          id: id,
          action: 'makeDefault'
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
          this.backToAccount();
          this.paymentMethods = response.cards;
          this.renderPaymentMethodsList(this.paymentMethods);
          return util.ctl('Menu').popOffBackButtonWithoutAction();
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
  saveChanges: function(callback) {
    var card, f, field, paymentMethodId, values;
    values = this.getEditPaymentMethodForm().getValues();
    card = {
      number: values['card_number'],
      cvc: values['card_cvc'],
      exp_month: values['card_exp_month'],
      exp_year: values['card_exp_year'],
      address_zip: "" + values['card_billing_zip']
    };
    for (f in card) {
      field = card[f];
      if (field === "") {
        navigator.notification.alert("All fields are required.", (function() {}), "Error");
        return;
      }
    }
    Stripe.setPublishableKey(util.STRIPE_PUBLISHABLE_KEY);
    paymentMethodId = this.getEditPaymentMethodForm().config.paymentMethodId;
    values['id'] = paymentMethodId;
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Stripe.card.createToken(card, (function(_this) {
      return function(status, response) {
        var stripe_token;
        if (response.error) {
          Ext.Viewport.setMasked(false);
          return navigator.notification.alert(response.error.message, (function() {}), "Error");
        } else {
          stripe_token = response.id;
          return Ext.Ajax.request({
            url: util.WEB_SERVICE_BASE_URL + "user/edit",
            params: Ext.JSON.encode({
              version: util.VERSION_NUMBER,
              user_id: localStorage['purpleUserId'],
              token: localStorage['purpleToken'],
              card: {
                stripe_token: stripe_token
              }
            }),
            headers: {
              'Content-Type': 'application/json'
            },
            timeout: 30000,
            method: 'POST',
            scope: _this,
            success: function(response_obj) {
              var c, ref;
              Ext.Viewport.setMasked(false);
              response = Ext.JSON.decode(response_obj.responseText);
              if (response.success) {
                this.paymentMethods = response.cards;
                delete localStorage['purpleDefaultPaymentMethodId'];
                ref = response.cards;
                for (c in ref) {
                  card = ref[c];
                  if (card["default"]) {
                    localStorage['purpleDefaultPaymentMethodId'] = card.id;
                    localStorage['purpleDefaultPaymentMethodDisplayText'] = card.brand + " *" + card.last4;
                  }
                }
                this.refreshAccountPaymentMethodField();
                util.ctl('Vehicles').vehicles = response.vehicles;
                util.ctl('Orders').orders = response.orders;
                this.backToPaymentMethods();
                this.renderPaymentMethodsList(this.paymentMethods);
                util.ctl('Menu').popOffBackButtonWithoutAction();
                if (typeof callback === 'function') {
                  return callback();
                }
              } else {
                return navigator.notification.alert(response.message, (function() {}), "Error");
              }
            },
            failure: function(response_obj) {
              Ext.Viewport.setMasked(false);
              response = Ext.JSON.decode(response_obj.responseText);
              return console.log(response);
            }
          });
        }
      };
    })(this));
  },
  refreshAccountPaymentMethodField: function() {
    var c, card, ref, ref1, ref2, ref3, results;
    if ((ref = this.getAccountPaymentMethodField()) != null) {
      ref.setValue("Add a Card");
    }
    if ((localStorage['purpleDefaultPaymentMethodId'] != null) && localStorage['purpleDefaultPaymentMethodId'] !== '') {
      if (this.paymentMethods != null) {
        ref1 = this.paymentMethods;
        results = [];
        for (c in ref1) {
          card = ref1[c];
          if (card["default"]) {
            if (card.id !== localStorage['purpleDefaultPaymentMethodId']) {
              alert("Error #289");
            }
            localStorage['purpleDefaultPaymentMethodDisplayText'] = card.brand + " *" + card.last4;
            if ((ref2 = this.getAccountPaymentMethodField()) != null) {
              ref2.setValue(localStorage['purpleDefaultPaymentMethodDisplayText']);
            }
            break;
          } else {
            results.push(void 0);
          }
        }
        return results;
      } else if ((localStorage['purpleDefaultPaymentMethodDisplayText'] != null) && localStorage['purpleDefaultPaymentMethodDisplayText'] !== '') {
        return (ref3 = this.getAccountPaymentMethodField()) != null ? ref3.setValue(localStorage['purpleDefaultPaymentMethodDisplayText']) : void 0;
      }
    }
  },
  initAccountPaymentMethodField: function(field) {
    this.refreshAccountPaymentMethodField();
    return field.element.on('tap', (function(_this) {
      return function() {
        return _this.accountPaymentMethodFieldTap();
      };
    })(this));
  },
  accountPaymentMethodFieldTap: function(suppressBackButtonBehavior) {
    if (suppressBackButtonBehavior == null) {
      suppressBackButtonBehavior = false;
    }
    this.getAccountTabContainer().setActiveItem(Ext.create('Purple.view.PaymentMethods'));
    if (!suppressBackButtonBehavior) {
      return util.ctl('Menu').pushOntoBackButton((function(_this) {
        return function() {
          return _this.backToAccount();
        };
      })(this));
    }
  }
});
