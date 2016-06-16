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
  # not guaranteed to be up-to-date; but it is a holding place for this info
  # every time the dispatch/availability endpoint is hit
  subscriptionUsage: null

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
  updateSubscriptionLocalStorageData: (response) ->
    localStorage['purpleSubscriptionId'] = response.user.subscription_id
    localStorage['purpleSubscriptionExpirationTime'] = response.user.subscription_expiration_time
    localStorage['purpleSubscriptionAutoRenew'] = response.user.subscription_auto_renew
    localStorage['purpleSubscriptionPeriodStartTime'] = response.user.subscription_period_start_time
    localStorage['purpleSubscriptionName'] = if response.user.subscription_id then response.system.subscriptions[response.user.subscription_id].name else "None"
    @refreshSubscriptionsField()

  # give it a user/details response (or similar format)
  updateSubscriptionRelatedData: (response) ->
    @updateSubscriptionLocalStorageData response
    @subscriptions = response.system.subscriptions
    @renderSubscriptions @subscriptions
    
  showAd: (passThruCallbackFn, actionCallbackFn) ->
    Ext.Msg.show
      cls: 'subscription-ad'
      title: ''
      message: """
        <span class="fake-title">Try our Monthly<br />Membership</span>
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

  isSubscribed: ->
    localStorage['purpleSubscriptionId']? and localStorage['purpleSubscriptionId'] isnt "0"

  hasAutoRenewOn: ->
    localStorage['purpleSubscriptionAutoRenew']? and localStorage['purpleSubscriptionAutoRenew'] is "true"

  renderSubscriptions: (subscriptions) ->
    subChoicesContainer = @getSubscriptionChoicesContainer()
    if not subChoicesContainer?
      return
    subChoicesContainer.removeAll yes, yes
    items = []
    items.push
      xtype: 'component'
      flex: 0
      html: if @isSubscribed()
        if @hasAutoRenewOn()
          """
            You're subscribed! You can cancel at any time.
          """
        else
          """
            You have unsubscribed, your membership ends #{
            Ext.util.Format.date(
              new Date(localStorage['purpleSubscriptionExpirationTime'] * 1000),
              "F j, Y"
            )}.
          """
      else
        """
          Select a plan. You can cancel at any time.
        """
      cls: 'loose-text'
    for s in Object.keys(subscriptions).sort(
      (a, b) -> # always list a currently subscribed option first
        switch localStorage['purpleSubscriptionId']
          when a then -1
          when b then 1
          else parseInt(a) - parseInt(b) # otherwise, order by subscription id
    )
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
      items.push
        xtype: 'textfield'
        flex: 0
        label: "#{sub.name} - $#{util.centsToDollars(sub.price)}"
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
      innerItems = [
        {
          xtype: 'component'
          margin: '5 0 10 0'
          width: '100%'
          style: "text-align: center;"
          html: """
            <ul style="list-style: bullet;">
              <li #{if sub.num_free_one_hour then '' else 'style="display: none;"'}>
                #{sub.num_free_one_hour} one-hour deliveries per month
              </li>
              <li #{if sub.num_free_three_hour then '' else 'style="display: none;"'}>
                #{sub.num_free_three_hour} three-hour deliveries per month
              </li>
              <li #{if sub.discount_one_hour then '' else 'style="display: none;"'}>
                $4 for additional orders
              </li>
              <li #{if sub.discount_three_hour then '' else 'style="display: none;"'}>
                $2.50 for additional orders
              </li>
              <li #{if sub.num_free_tire_pressure_check then '' else 'style="display: none;"'}>
                #{sub.num_free_tire_pressure_check} tire pressure fill-up per month
              </li>
            </ul>
          """
        }
      ]
      if localStorage['purpleSubscriptionId'] is "" + sub.id
        if @hasAutoRenewOn()
          innerItems.push
            xtype: 'button'
            ui: 'action'
            cls: 'button-pop'
            text: "Unsubscribe"
            flex: 0
            margin: '0 0 15 0'
            handler: => @unsubscribe()
        else
          innerItems.push
            xtype: 'button'
            ui: 'action'
            cls: 'button-pop'
            text: "Restore Subscription"
            flex: 0
            margin: '0 0 15 0'
            handler: => @restoreSubscription()
      else
        innerItems.push
          xtype: 'button'
          ui: 'action'
          cls: 'button-pop'
          text: "Subscribe to #{sub.name}"
          flex: 0
          margin: '0 0 15 0'
          handler: ((subId) => =>
            @askSubscribe subId, (=>
              util.ctl('Menu').popOffBackButton()
              @getMainContainer().getItems().getAt(0).select 0, no, no
            )
          )(sub.id)
        
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
        items: innerItems    
          
    subChoicesContainer.add items

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
        @getAccountTabContainer().setActiveItem @getAccountForm()
        @getAccountTabContainer().remove(
          @getSubscriptions(),
          yes
        )

  askSubscribe: (id, callback) ->
    util.confirm(
      "",
      "Subscribe to the #{@subscriptions[id].name} plan?",
      (=> @subscribe id, callback),
      null,
      'Yes',
      'No'
    )

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
          util.alert(
            """
              Your subscription will automatically renew on #{
              Ext.util.Format.date(
                new Date(localStorage['purpleSubscriptionExpirationTime'] * 1000),
                "F j, Y"
              )}.
            """,
            "Welcome to the #{@subscriptions[localStorage['purpleSubscriptionId']].name} Plan!"
          )
        else
          util.alert response.message, "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  unsubscribe: ->
    util.confirm(
      """
        Your monthly membership will expire #{
        Ext.util.Format.date(
          new Date(localStorage['purpleSubscriptionExpirationTime'] * 1000),
          "F j, Y"
        )}.
      """,
      'Unsubscribe?',
      (=> @setAutoRenew null, 0),
      null,
      'Yes',
      'No'
    )

  # unlikely, but possible, bug: what if their subscription has just expired
  # while they were on this page, and then they hit Restore Subscription
  # or, how about if they hit Unsubscribe
  restoreSubscription: ->
    @setAutoRenew null, 1

  # the signature of this funciton is such that it could be the 'change' event
  # for a toggle field
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
