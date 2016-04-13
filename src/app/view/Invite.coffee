Ext.define 'Purple.view.Invite',
  extend: 'Ext.Container'
  xtype: 'invite'
  requires: [
    'Ext.form.*'
    'Ext.field.*'
    'Ext.Button'
    'Ext.XTemplate'
  ]
  config:
    layout:
      type: 'hbox'
      pack: 'start'
      align: 'start'
    height: '100%'
    cls: [
      'invite-form'
      'accent-bg'
      'slideable'
    ]
    scrollable:
      direction: 'vertical'
      directionLock: yes
      translatable:
        translationMethod: 'auto'
    plugins: [
      {
        xclass: 'Purple.plugin.NonListPullRefresh'
        pullRefreshText: 'pull down to refresh'
        releaseRefreshText: 'release to refresh'
        loadingText: 'loading...'
        pullTpl: new Ext.XTemplate("""
          <div class="x-list-pullrefresh">
            <div class="x-list-pullrefresh-wrap" style="width: {[Ext.Viewport.element.getWidth()]}px;">
              <img src="resources/images/center-map-icon.png" width="35" height="35" />
              <h3 class="x-list-pullrefresh-message" style="display:none">
                {message}
              </h3>
              <div class="x-list-pullrefresh-updated" style="display:none">
                last updated: <span>{lastUpdated:date("m/d/Y h:iA")}</span>
              </div>
            </div>
          </div>
          <div class='x-list-emptytext' style='display:none;'>
            {[(navigator.onLine ? 'no orders' : 'unable to connect to internet<br />pull down to refresh')]}
          </div>
        """)
        refreshFn: (plugin) ->
          refresher = ->
            cont = plugin.getParentCmp()
            scroller = cont.getScrollable().getScroller()
            cont.refreshView ->
              scroller.minPosition.y = 0
              scroller.scrollTo null, 0, true
              plugin.resetRefreshState()
          refresher()
          return false
      }
    ]
    scope: this
    listeners:
      initialize: ->
        @refreshView()
    items: [
      {
        xtype: 'spacer'
        flex: 1
      }
      {
        xtype: 'container'
        id: 'inviteInnerContainer'
        flex: 0
        width: '85%'
        layout:
          type: 'vbox'
          pack: 'start'
          align: 'start'
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]

  refreshView: (callback = null) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/details"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          util.ctl('Orders').orders = response.orders
          util.ctl('Orders').loadOrdersList()
          util.ctl('Vehicles').vehicles = response.vehicles
          util.ctl('Vehicles').loadVehiclesList()
          localStorage['purpleUserReferralCode'] = response.user.referral_code
          localStorage['purpleUserReferralGallons'] = "" + response.user.referral_gallons
          @referralReferredValue = response.system.referral_referred_value
          @referralReferrerGallons = response.system.referral_referrer_gallons
          Ext.getCmp('inviteInnerContainer').removeAll yes, yes
          @populate()
          callback?()
        else
          navigator.notification.alert response.message, (->), "Error"
        Ext.Viewport.setMasked false
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  populate: ->
    inviteMessage = """
      Get $#{Math.floor(util.centsToDollars(Math.abs(@referralReferredValue)))} of gas for free when you use my coupon code, #{localStorage['purpleUserReferralCode']}. Download the Purple app, to fuel your car wherever you are: #{util.WEB_SERVICE_BASE_URL}app
    """
    inviteMessageTwitter = """
      Get $#{Math.floor(util.centsToDollars(Math.abs(@referralReferredValue)))} of gas for free when you use my coupon code, #{localStorage['purpleUserReferralCode']}. Download the Purple app for iPhone or Android.
    """
    Ext.getCmp('inviteInnerContainer').add [
      {
        xtype: 'component'
        flex: 0
        cls: 'heading'
        html: 'Get Free Gas!'
      }
      {
        xtype: 'component'
        flex: 0
        cls: [
          'horizontal-rule'
          'purple-rule'
        ]
      }
      {
        xtype: 'component'
        flex: 0
        html: """
          Get <span style="font-weight: 900; color: #423774;">#{@referralReferrerGallons} gallons free</span> for each of your friends that use your coupon code on their first order. They get $#{Math.floor(util.centsToDollars(Math.abs(@referralReferredValue)))} off!

          <div style="text-align: center; padding: 35px 0px 0px 0px;">
            You have <span style="font-weight: 900; color: #423774;">#{localStorage['purpleUserReferralGallons']} free gallons</span>
          </div>

          <div style="text-align: center; padding: 30px 0px 0px 0px;">
            Share Your Coupon Code: <span style="font-weight: 900; color: #FB8454; font-family: 'Museo Sans Rounded'">#{localStorage['purpleUserReferralCode']}</span>
          </div>
        """
        cls: 'loose-text'
      }
      {
        xtype: 'container'
        flex: 0
        cls: 'smaller-button-pop'
        width: '100%'
        padding: '5 0 5 0'
        layout:
          type: 'vbox'
          pack: 'center'
          align: 'center'
        items: [
          {
            xtype: 'container'
            flex: 0
            width: '100%'
            padding: '7 0 15 0'
            layout:
              type: 'hbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Email'
                flex: 0
                width: 125
                margin: '0 5 0 0'
                handler: ->
                  plugins?.socialsharing?.shareViaEmail(
                    inviteMessage,
                    "$10 of Gas Free, Download the Purple App",
                    null,
                    null,
                    null,
                    null,
                    (->), # success, first arg either true or false
                    (-> navigator.notification.alert 'Please ensure Mail is enabled on your device.', (->), "Not Available")  # fatal error
                  )
              }
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop button-pop-facebook'
                text: 'Facebook'
                flex: 0
                width: 125
                margin: '0 0 0 5'
                handler: ->
                  plugins?.socialsharing?.shareViaFacebookWithPasteMessageHint(
                    inviteMessage,
                    null, # img
                    "#{util.WEB_SERVICE_BASE_URL}app",
                    "Press \"Paste\" for a sample message."
                    (->),
                    (->)
                  )
              }
            ]
          }
          {
            xtype: 'container'
            flex: 0
            width: '100%'
            padding: '0 0 5 0'
            layout:
              type: 'hbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop button-pop-dark'
                text: 'Text'
                flex: 0
                width: 125
                margin: '0 5 0 0'
                handler: ->
                  #@up().up().up().fireEvent 'sendInvites'
                  plugins?.socialsharing?.shareViaSMS(
                    inviteMessage,
                    null,
                    (->),
                    (->)
                  )
              }
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop button-pop-twitter'
                text: 'Tweet'
                flex: 0
                width: 125
                margin: '0 0 0 5'
                handler: ->
                  plugins?.socialsharing?.shareViaTwitter(
                    inviteMessageTwitter,
                    null, # img
                    "#{util.WEB_SERVICE_BASE_URL}app"
                  )
              }
            ]
          }
        ]
      }        
    ]
