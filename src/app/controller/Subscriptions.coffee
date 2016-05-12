Ext.define 'Purple.controller.Subscriptions',
  extend: 'Ext.app.Controller'
  requires: [
    'Purple.view.Subscriptions'
  ]
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      accountTabContainer: '#accountTabContainer'
      accountForm: 'accountform'
      requestGasTabContainer: '#requestGasTabContainer'
      requestConfirmationForm: 'requestconfirmationform'
      subscriptions: 'subscriptions' # the Subscriptions page
      subscriptionChoicesContainer: '#subscriptionChoicesContainer'
      accountSubscriptionsField: '#accountSubscriptionsField'
      autoRenewField: '[ctype=autoRenewField]'
    control:
      subscriptions:
        loadSubscriptions: 'loadSubscriptions'
        subscribe: 'subscribe'
      accountSubscriptionsField:
        initialize: 'initAccountSubscriptionsField'
      autoRenewField:
        change: 'setAutoRenew'

  subscriptions: null

  launch: ->
    @callParent arguments

  initAccountSubscriptionsField: (field) ->
    @refreshSubscriptionsField()
    field.element.on 'tap', =>
      @subscriptionsFieldTap()

  refreshSubscriptionsField: ->
    @getAccountSubscriptionsField()?.setValue "None"

    if localStorage['purpleSubscriptionId']? and
    localStorage['purpleSubscriptionId'] isnt '0'
      @getAccountSubscriptionsField()?.setValue(
        localStorage['purpleSubscriptionName']
      )

  # give it a user/details response (or similar format)
  updateSubscriptionRelatedData: (response) ->
    localStorage['purpleSubscriptionId'] = response.user.subscription_id
    localStorage['purpleSubscriptionExpirationTime'] = response.user.subscription_expiration_time
    localStorage['purpleSubscriptionAutoRenew'] = response.user.subscription_auto_renew
    localStorage['purpleSubscriptionPeriodStartTime'] = response.user.subscription_period_start_time
    localStorage['purpleSubscriptionName'] = if response.user.subscription_id then response.system.subscriptions[response.user.subscription_id].name else "None"
    @refreshSubscriptionsField()
    @subscriptions = response.system.subscriptions
    @renderSubscriptions @subscriptions
    
  showAd: (passThruCallbackFn, actionCallbackFn) ->
    Ext.Msg.show
      cls: 'subscription-ad'
      title: ''
      message: """
        <span class="fake-title">Try our monthly<br />membership!</span>
        <br />Get deliveries free when you join!
        """
      buttons: [
        {
          ui: 'action'
          text: "More Info"
          itemId: "more-info"
        }
        {
          ui: 'normal'
          text: "Not Now"
          itemId: "hide"
        }
      ]
      fn: (buttonId) ->
        switch buttonId
          when 'hide' then passThruCallbackFn?()
          when 'more-info' then actionCallbackFn?()
      hideOnMaskTap: no

  loadSubscriptions: (forceUpdate = no, callback = null) ->
    if not forceUpdate and @subscriptions?
      @renderSubscriptions @subscriptions
    else
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}user/details"
        params: Ext.JSON.encode
          version: util.VERSION_NUMBER
          user_id: localStorage['purpleUserId']
          token: localStorage['purpleToken']
          os: Ext.os.name
        headers:
          'Content-Type': 'application/json'
        timeout: 30000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            @updateSubscriptionRelatedData response
            callback?()
          else
            navigator.notification.alert response.message, (->), "Error"
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          if util.ctl('Account').isCourier()
            navigator.notification.alert "Slow or no internet connection.", (->), "Error"
          response = Ext.JSON.decode response_obj.responseText
          console.log response

  renderSubscriptions: (subscriptions) ->
    subChoicesContainer = @getSubscriptionChoicesContainer()
    if not subChoicesContainer?
      return
    subChoicesContainer.removeAll yes, yes
    items = []
    items.push
      xtype: 'component'
      flex: 0
      html: """
        Select one of the plans to get more information.
        You can cancel at any time.
      """
      cls: 'loose-text'
    for s in Object.keys(subscriptions).sort(
      (a, b) -> localStorage['purpleSubscriptionId'] isnt "" + a
    ) # get the current subscription on top
      sub = subscriptions[s]
      cls = [
        'bottom-margin'
        'faq-question'
      ]
      if localStorage['purpleSubscriptionId'] isnt "" + sub.id
        cls = cls.concat [
          'click-to-edit'
          'point-down'
        ]
      else
        cls = cls.concat [
          'highlighted'
        ]
      if localStorage['purpleSubscriptionId'] is "" + sub.id
        items.push
          xtype: 'togglefield'
          ctype: 'autoRenewField'
          ui: 'plain'
          flex: 0
          name: 'auto_renew'
          value: localStorage['purpleSubscriptionAutoRenew'] is 'true'
          label: 'Auto-renew?'
          labelWidth: 140
          cls: [
            'bottom-margin'
            'auto-renew-toggle'
          ]
      items.push
        xtype: 'textfield'
        flex: 0
        label: "#{sub.name} - $#{util.centsToDollars(sub.price)} / month"
        labelWidth: '100%'
        cls: cls
        disabled: yes
        listeners:
          initialize: ((subId) -> (field) ->
            field.element.on 'tap', ->
              if localStorage['purpleSubscriptionId'] isnt "" + subId
                text = Ext.ComponentQuery.query("#level-#{subId}-details")[0]
                if text.isHidden()
                  text.show()
                  field.addCls 'point-up'
                else
                  text.hide()
                  field.removeCls 'point-up')(sub.id)
      items.push
        xtype: 'container'
        flex: 0
        width: '100%'
        id: "level-#{sub.id}-details"
        cls: [
          'accordion-text'
          'smaller-button-pop'
        ]
        showAnimation: 'fadeIn'
        hidden: localStorage['purpleSubscriptionId'] isnt "" + sub.id
        items: [
          {
            xtype: 'component'
            margin: '5 0 10 0'
            width: '100%'
            style: "text-align: center;"
            html: """
              3 x 3 hour orders
            """
          }
          {
            xtype: 'button'
            ui: 'action'
            cls: 'button-pop'
            hidden: localStorage['purpleSubscriptionId'] is "" + sub.id
            text: "Subscribe to #{sub.name}"
            flex: 0
            margin: '0 0 15 0'
            handler: ((subId) -> ->
              @up().up().up().up().fireEvent 'subscribe', subId, ->
                util.ctl('Menu').popOffBackButton())(sub.id)
          }
        ]
    subChoicesContainer.add items

  backToPreviousPage: ->
    if @requestGasTabActive
      @getRequestGasTabContainer().setActiveItem @getRequestConfirmationForm()
      @getRequestGasTabContainer().remove(
        @getSubscriptions(),
        yes
      )
      # if @getEditPaymentMethodForm()?
      #   @getRequestGasTabContainer().remove(
      #     @getEditPaymentMethodForm(),
      #     yes
      #   )
    else
      @getAccountTabContainer().setActiveItem @getAccountForm()
      @getAccountTabContainer().remove(
        @getSubscriptions(),
        yes
      )
      # if @getEditPaymentMethodForm()?
      #   @getAccountTabContainer().remove(
      #     @getEditPaymentMethodForm(),
      #     yes
      #   )

  subscriptionsFieldTap: (suppressBackButtonBehavior = no, requestGasTabActive = no) ->
    @requestGasTabActive = requestGasTabActive

    if @requestGasTabActive
      @getRequestGasTabContainer().setActiveItem(
        Ext.create 'Purple.view.Subscriptions'
      )
    else 
      @getAccountTabContainer().setActiveItem(
        Ext.create 'Purple.view.Subscriptions'
      )
    if not suppressBackButtonBehavior
      util.ctl('Menu').pushOntoBackButton =>
        @backToPreviousPage()

  subscribe: (id, callback) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/subscriptions/subscribe"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        os: Ext.os.name
        subscription_id: id
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @updateSubscriptionRelatedData response
          callback?()
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        if util.ctl('Account').isCourier()
          navigator.notification.alert "Slow or no internet connection.", (->), "Error"
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  setAutoRenew: (_, value) ->
    currAutoRenewVal = switch localStorage['purpleSubscriptionAutoRenew']
      when 'true' then 1
      when 'false' then 0
      else 0
    if currAutoRenewVal isnt value
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}user/subscriptions/set-auto-renew"
        params: Ext.JSON.encode
          version: util.VERSION_NUMBER
          user_id: localStorage['purpleUserId']
          token: localStorage['purpleToken']
          os: Ext.os.name
          subscription_auto_renew: not not value
        headers:
          'Content-Type': 'application/json'
        timeout: 30000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            @updateSubscriptionRelatedData response
          else
            navigator.notification.alert response.message, (->), "Error"
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          if util.ctl('Account').isCourier()
            navigator.notification.alert "Slow or no internet connection.", (->), "Error"
          response = Ext.JSON.decode response_obj.responseText
          console.log response
