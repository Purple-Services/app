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
      accountSubscriptionsField: '#accountSubscriptionsField'
    control:
      accountSubscriptionsField:
        initialize: 'initAccountSubscriptionsField'

  launch: ->
    @callParent arguments

  initAccountSubscriptionsField: (field) ->
    @refreshSubscriptionsField()
    field.element.on 'tap', =>
      @subscriptionsFieldTap()

  refreshSubscriptionsField: ->
    @getAccountSubscriptionsField()?.setValue "None"

    if localStorage['purpleSubscriptionLevel']? and
    localStorage['purpleSubscriptionLevel'] isnt ''
      @getAccountSubscriptionsField()?.setValue(
        localStorage['purpleSubscriptionLevel']
      )
    
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
          text: "No Thanks"
          itemId: "hide"
        }
      ]
      fn: (buttonId) ->
        switch buttonId
          when 'hide' then passThruCallbackFn?()
          when 'more-info' then actionCallbackFn?()
      hideOnMaskTap: no

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
