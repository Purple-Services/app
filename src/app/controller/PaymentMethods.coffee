Ext.define 'Purple.controller.PaymentMethods'
  extend: 'Ext.app.Controller'
  requires: [
    'Purple.view.EditPaymentMethodForm'
  ]
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      accountTabContainer: '#accountTabContainer'
      paymentMethods: 'paymentmethods' # the PaymentMethods *page*
      paymentMethodsList: '[ctype=paymentMethodsList]'
      editPaymentMethodForm: 'editpaymentmethodform'
      editPaymentMethodFormHeading: '[ctype=editPaymentMethodFormHeading]'
      backToPaymentMethodsButton: '[ctype=backToPaymentMethodsButton]'
      accountPaymentMethodField: '#accountPaymentMethodField'
      accountPaymentMethodIdField: '#accountPaymentMethodIdField'
    control:
      paymentMethods:
        editPaymentMethod: 'showEditPaymentMethodForm'
        loadPaymentMethodsList: 'loadPaymentMethodsList'
      editPaymentMethodForm:
        backToPaymentMethods: 'backToPaymentMethods'
        saveChanges: 'saveChanges'
        deletePaymentMethod: 'deletePaymentMethod'
      editPaymentMethodFormYear:
        change: 'yearChanged'
      editPaymentMethodFormMake:
        change: 'makeChanged'
      accountPaymentMethodField:
        initialize: 'initAccountPaymentMethodField'

  # will be null until they log in
  paymentMethods: null

  launch: ->
    @callParent arguments

  getPaymentMethodById: (id) ->
    for v in @paymentMethods
      if v['id'] is id
        paymentMethod = v
        break
    return paymentMethod

  showEditPaymentMethodForm: (paymentMethodId = 'new') ->
    @getAccountTabContainer().setActiveItem(
      Ext.create 'Purple.view.EditPaymentMethodForm',
        paymentMethodId: paymentMethodId
    )

    @getEditPaymentMethodFormHeading().setHtml(
      if paymentMethodId is 'new'
        'Add Card'
      else
        'Edit Card'
    )
    
    # if paymentMethodId isnt 'new'
    #   paymentMethod = @getPaymentMethodById paymentMethodId
    #   @getEditPaymentMethodFormYear().setValue paymentMethod['year']

  backToPaymentMethods: ->
    @getAccountTabContainer().setActiveItem @getPaymentMethods()
    @getAccountTabContainer().remove(
      @getEditPaymentMethodForm(),
      yes
    )

  loadPaymentMethodsList: ->
    @renderPaymentMethodsList @paymentMethods
  
  renderPaymentMethodsList: (paymentMethods) ->
    list =  @getPaymentMethodsList()
    if not list?
      return
    list.removeAll yes, yes
    for p in paymentMethods
      list.add
        xtype: 'textfield'
        id: "pmid_#{p.id}"
        flex: 0
        label: "**** **** **** #{v.last4}"
        labelWidth: '100%'
        cls: [
          'bottom-margin'
        ]
        disabled: yes
        listeners:
          initialize: (field) =>
            field.element.on 'tap', =>
              pmid = field.getId().split('_')[1]
              @showEditPaymentMethodForm pmid

  saveChanges: ->
    Stripe.setPublishableKey util.STRIPE_PUBLISHABLE_KEY
    
    values = @getEditPaymentMethodForm().getValues()
    paymentMethodId = @getEditPaymentMethodForm().config.paymentMethodId
    values['id'] = paymentMethodId
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
      
    card =
      number: values['card_number']
      cvc: values['card_cvc']
      exp_month: values['card_exp_month']
      exp_year: values['card_exp_year']
      
    Stripe.card.createToken card, (status, response) =>
      if response.error
        Ext.Viewport.setMasked false
        navigator.notification.alert response.error.message, (->), "Error"
      else
        stripe_token = response.id    
        Ext.Ajax.request
          url: "#{util.WEB_SERVICE_BASE_URL}user/edit"
          params: Ext.JSON.encode
            user_id: localStorage['purpleUserId']
            token: localStorage['purpleToken']
            card:
              stripe_token: stripe_token
          headers:
            'Content-Type': 'application/json'
          timeout: 30000
          method: 'POST'
          scope: this
          success: (response_obj) ->
            Ext.Viewport.setMasked false
            response = Ext.JSON.decode response_obj.responseText
            if response.success
              util.ctl('Vehicles').vehicles = response.vehicles
              util.ctl('Orders').orders = response.orders
              @backToPaymentMethods()
              @renderPaymentMethodsList @paymentMethods
            else
              navigator.notification.alert response.message, (->), "Error"
          failure: (response_obj) ->
            Ext.Viewport.setMasked false
            response = Ext.JSON.decode response_obj.responseText
            console.log response

  deletePaymentMethod: (paymentMethodId) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/edit"
      params: Ext.JSON.encode
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        paymentMethod:
          id: paymentMethodId
          active: 0
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @paymentMethods = response.paymentMethods
          util.ctl('Orders').orders = response.orders
          @backToPaymentMethods()
          @renderPaymentMethodsList @paymentMethods
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  initAccountPaymentMethodField: (field) ->
    if localStorage['purpleDefaultPaymentMethodId']? and
    localStorage['purpleDefaultPaymentMethodId'] isnt ''
      @getAccountPaymentMethodIdField().setValue(
        localStorage['purpleDefaultPaymentMethodId']
      )
      @getAccountPaymentMethodField().setValue(
        "asterisked num " + localStorage['purpleDefaultPaymentMethodId']
      )
    else
      @getAccountPaymentMethodIdField().setValue ''
      @getAccountPaymentMethodField().setValue "Add/Edit Cards"
    field.element.on 'tap', =>
      @accountPaymentMethodFieldTap()

  accountPaymentMethodFieldTap: ->
    # id = @getAccountPaymentMethodIdField().getValue()
    @getAccountTabContainer().setActiveItem(
      Ext.create 'Purple.view.PaymentMethods'
    )
