Ext.define('Purple.view.Invite', {
  extend: 'Ext.Container',
  xtype: 'invite',
  requires: ['Ext.form.*', 'Ext.field.*', 'Ext.Button', 'Ext.XTemplate'],
  config: {
    layout: {
      type: 'hbox',
      pack: 'start',
      align: 'start'
    },
    height: '100%',
    cls: ['invite-form', 'accent-bg', 'slideable'],
    scrollable: {
      direction: 'vertical',
      directionLock: true,
      translatable: {
        translationMethod: 'auto'
      }
    },
    plugins: [
      {
        xclass: 'Purple.plugin.NonListPullRefresh',
        pullRefreshText: 'pull down to refresh',
        releaseRefreshText: 'release to refresh',
        loadingText: 'loading...',
        pullTpl: new Ext.XTemplate("<div class=\"x-list-pullrefresh\">\n  <div class=\"x-list-pullrefresh-wrap\" style=\"width: {[Ext.Viewport.element.getWidth()]}px;\">\n    <img src=\"resources/images/center-map-icon.png\" width=\"35\" height=\"35\" />\n    <h3 class=\"x-list-pullrefresh-message\" style=\"display:none\">\n      {message}\n    </h3>\n    <div class=\"x-list-pullrefresh-updated\" style=\"display:none\">\n      last updated: <span>{lastUpdated:date(\"m/d/Y h:iA\")}</span>\n    </div>\n  </div>\n</div>\n<div class='x-list-emptytext' style='display:none;'>\n  {[(navigator.onLine ? 'no orders' : 'unable to connect to internet<br />pull down to refresh')]}\n</div>"),
        refreshFn: function(plugin) {
          var refresher;
          refresher = function() {
            var cont, scroller;
            cont = plugin.getParentCmp();
            scroller = cont.getScrollable().getScroller();
            return cont.refreshView(function() {
              scroller.minPosition.y = 0;
              scroller.scrollTo(null, 0, true);
              return plugin.resetRefreshState();
            });
          };
          refresher();
          return false;
        }
      }
    ],
    scope: this,
    listeners: {
      initialize: function() {
        return this.refreshView();
      }
    },
    items: [
      {
        xtype: 'spacer',
        flex: 1
      }, {
        xtype: 'container',
        id: 'inviteInnerContainer',
        flex: 0,
        width: '85%',
        layout: {
          type: 'vbox',
          pack: 'start',
          align: 'start'
        }
      }, {
        xtype: 'spacer',
        flex: 1
      }
    ]
  },
  refreshView: function(callback) {
    if (callback == null) {
      callback = null;
    }
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: util.WEB_SERVICE_BASE_URL + "user/details",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken']
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
          util.ctl('Orders').orders = response.orders;
          util.ctl('Orders').loadOrdersList();
          util.ctl('Vehicles').vehicles = response.vehicles;
          util.ctl('Vehicles').loadVehiclesList();
          localStorage['purpleUserReferralCode'] = response.user.referral_code;
          localStorage['purpleUserReferralGallons'] = "" + response.user.referral_gallons;
          this.referralReferredValue = response.system.referral_referred_value;
          this.referralReferrerGallons = response.system.referral_referrer_gallons;
          Ext.getCmp('inviteInnerContainer').removeAll(true, true);
          this.populate();
          if (typeof callback === "function") {
            callback();
          }
        } else {
          navigator.notification.alert(response.message, (function() {}), "Error");
        }
        return Ext.Viewport.setMasked(false);
      },
      failure: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        return console.log(response);
      }
    });
  },
  populate: function() {
    var inviteMessage, inviteMessageTwitter;
    inviteMessage = "Get $" + (Math.floor(util.centsToDollars(Math.abs(this.referralReferredValue)))) + " of gas for free when you use my coupon code, " + localStorage['purpleUserReferralCode'] + ". Download the Purple app, to fuel your car wherever you are: " + util.WEB_SERVICE_BASE_URL + "app";
    inviteMessageTwitter = "Get $" + (Math.floor(util.centsToDollars(Math.abs(this.referralReferredValue)))) + " of gas for free when you use my coupon code, " + localStorage['purpleUserReferralCode'] + ". Download the Purple app for iPhone or Android.";
    return Ext.getCmp('inviteInnerContainer').add([
      {
        xtype: 'component',
        flex: 0,
        cls: 'heading',
        html: 'Get Free Gas!'
      }, {
        xtype: 'component',
        flex: 0,
        cls: 'horizontal-rule'
      }, {
        xtype: 'component',
        flex: 0,
        html: "Get <span style=\"font-weight: 900\">" + this.referralReferrerGallons + " gallons free</span> for each of your friends that use your coupon code on their first order. They get $" + (Math.floor(util.centsToDollars(Math.abs(this.referralReferredValue)))) + " off!\n\n<div style=\"text-align: center; padding: 35px 0px 0px 0px; color: #ba1c8d\">\n  You have <span style=\"font-weight: 900\">" + localStorage['purpleUserReferralGallons'] + " free gallons</span>\n</div>\n\n<div style=\"text-align: center; padding: 30px 0px 0px 0px; color: #ba1c8d\">\n  Share Your Coupon Code: <span style=\"font-weight: 900\">" + localStorage['purpleUserReferralCode'] + "</span>\n</div>",
        cls: 'loose-text'
      }, {
        xtype: 'container',
        flex: 0,
        cls: 'smaller-button-pop',
        width: '100%',
        padding: '5 0 5 0',
        layout: {
          type: 'vbox',
          pack: 'center',
          align: 'center'
        },
        items: [
          {
            xtype: 'container',
            flex: 0,
            width: '100%',
            padding: '7 0 15 0',
            layout: {
              type: 'hbox',
              pack: 'center',
              align: 'center'
            },
            items: [
              {
                xtype: 'button',
                ui: 'action',
                cls: 'button-pop',
                text: 'Email',
                flex: 0,
                width: 125,
                margin: '0 5 0 0',
                handler: function() {
                  var ref;
                  return typeof plugins !== "undefined" && plugins !== null ? (ref = plugins.socialsharing) != null ? ref.shareViaEmail(inviteMessage, "$10 of Gas Free, Download the Purple App", null, null, null, null, (function() {}), (function() {})) : void 0 : void 0;
                }
              }, {
                xtype: 'button',
                ui: 'action',
                cls: 'button-pop button-pop-facebook',
                text: 'Facebook',
                flex: 0,
                width: 125,
                margin: '0 0 0 5',
                handler: function() {
                  var ref;
                  return typeof plugins !== "undefined" && plugins !== null ? (ref = plugins.socialsharing) != null ? ref.shareViaFacebookWithPasteMessageHint(inviteMessage, null, util.WEB_SERVICE_BASE_URL + "app", "Press \"Paste\" for a sample message.", (function() {}), (function() {})) : void 0 : void 0;
                }
              }
            ]
          }, {
            xtype: 'container',
            flex: 0,
            width: '100%',
            padding: '0 0 5 0',
            layout: {
              type: 'hbox',
              pack: 'center',
              align: 'center'
            },
            items: [
              {
                xtype: 'button',
                ui: 'action',
                cls: 'button-pop button-pop-dark',
                text: 'Text',
                flex: 0,
                width: 125,
                margin: '0 5 0 0',
                handler: function() {
                  var ref;
                  return typeof plugins !== "undefined" && plugins !== null ? (ref = plugins.socialsharing) != null ? ref.shareViaSMS(inviteMessage, null, (function() {}), (function() {})) : void 0 : void 0;
                }
              }, {
                xtype: 'button',
                ui: 'action',
                cls: 'button-pop button-pop-twitter',
                text: 'Tweet',
                flex: 0,
                width: 125,
                margin: '0 0 0 5',
                handler: function() {
                  var ref;
                  return typeof plugins !== "undefined" && plugins !== null ? (ref = plugins.socialsharing) != null ? ref.shareViaTwitter(inviteMessageTwitter, null, util.WEB_SERVICE_BASE_URL + "app") : void 0 : void 0;
                }
              }
            ]
          }
        ]
      }
    ]);
  }
});
