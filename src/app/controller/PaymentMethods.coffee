Ext.define 'Purple.controller.PaymentMethods',
  extend: 'Ext.app.Controller'
  requires: [
    'Purple.view.EditPaymentMethodForm'
  ]
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      accountTabContainer: '#accountTabContainer'
      accountForm: 'accountform'
      requestGasTabContainer: '#requestGasTabContainer'
      requestConfirmationForm: 'requestconfirmationform'
      paymentMethods: 'paymentmethods' # the PaymentMethods *page*
      paymentMethodsList: '[ctype=paymentMethodsList]'
      editPaymentMethodForm: 'editpaymentmethodform'
      editPaymentMethodFormHeading: '[ctype=editPaymentMethodFormHeading]'
      backToPaymentMethodsButton: '[ctype=backToPaymentMethodsButton]'
      accountPaymentMethodField: '#accountPaymentMethodField'
      paymentMethodConfirmationField: '#paymentMethodConfirmationField'
      editPaymentMethodFormMonth: '[ctype=editPaymentMethodFormMonth]'
      editPaymentMethodFormYear: '[ctype=editPaymentMethodFormYear]'
      editPaymentMethodFormBillingZip: '[ctype=editPaymentMethodFormBillingZip]'
    control:
      paymentMethods:
        editPaymentMethod: 'showEditPaymentMethodForm'
        loadPaymentMethodsList: 'loadPaymentMethodsList'
        backToPreviousPage: 'backToPreviousPage'
      editPaymentMethodForm:
        backToPaymentMethods: 'backToPaymentMethods'
        saveChanges: 'saveChanges'
        deletePaymentMethod: 'deletePaymentMethod'
      editPaymentMethodFormMonth:
        initialize: 'initEditPaymentMethodFormMonth'
      editPaymentMethodFormYear:
        initialize: 'initEditPaymentMethodFormYear'
      editPaymentMethodFormMake:
        change: 'makeChanged'
      accountPaymentMethodField:
        initialize: 'initAccountPaymentMethodField'
      editPaymentMethodFormBillingZip:
        focus: 'focusEditPaymentMethodFormBillingZip'

  # will be null until they log in
  paymentMethods: null
  scrollToField: true

  launch: ->
    @callParent arguments

  getPaymentMethodById: (id) ->
    for v in @paymentMethods
      if v['id'] is id
        paymentMethod = v
        break
    return paymentMethod

  showEditPaymentMethodForm: (paymentMethodId = 'new', suppressBackButtonBehavior = no) ->
    # the way we have things set up, paymentMethodId is always 'new'
    if @requestGasTabActive
      @getRequestGasTabContainer().setActiveItem(
        Ext.create 'Purple.view.EditPaymentMethodForm',
          paymentMethodId: paymentMethodId
      )
    else
      @getAccountTabContainer().setActiveItem(
        Ext.create 'Purple.view.EditPaymentMethodForm',
          paymentMethodId: paymentMethodId
      )
    if not suppressBackButtonBehavior
      util.ctl('Menu').pushOntoBackButton =>
        @backToPaymentMethods()
      
    @getEditPaymentMethodFormHeading().setHtml(
      if paymentMethodId is 'new'
        'Add Card'
      else
        'Edit Card'
    )

  backToPaymentMethods: ->
    if @requestGasTabActive
      @getRequestGasTabContainer().setActiveItem @getPaymentMethods()
      @getRequestGasTabContainer().remove(
        @getEditPaymentMethodForm(),
        yes
      )
    else
      @getAccountTabContainer().setActiveItem @getPaymentMethods()
      @getAccountTabContainer().remove(
        @getEditPaymentMethodForm(),
        yes
      )

  backToPreviousPage: ->
    if @requestGasTabActive
      @getRequestGasTabContainer().setActiveItem @getRequestConfirmationForm()
      @getRequestGasTabContainer().remove(
        @getPaymentMethods(),
        yes
      )
      if @getEditPaymentMethodForm()?
        @getRequestGasTabContainer().remove(
          @getEditPaymentMethodForm(),
          yes
        )
    else
      @getAccountTabContainer().setActiveItem @getAccountForm()
      @getAccountTabContainer().remove(
        @getPaymentMethods(),
        yes
      )
      if @getEditPaymentMethodForm()?
        @getAccountTabContainer().remove(
          @getEditPaymentMethodForm(),
          yes
        )

  loadPaymentMethodsList: ->
    if @paymentMethods?
      @renderPaymentMethodsList @paymentMethods
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
          os: Ext.os.name # just an additional info
        headers:
          'Content-Type': 'application/json'
        timeout: 30000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            @paymentMethods = response.cards
            delete localStorage['purpleDefaultPaymentMethodId']
            for c, card of response.cards
              if card.default
                localStorage['purpleDefaultPaymentMethodId'] = card.id
                localStorage['purpleDefaultPaymentMethodDisplayText'] = """
                  #{card.brand} *#{card.last4}
                """
            @refreshPaymentMethodField()
            util.ctl('Orders').orders = response.orders
            util.ctl('Orders').loadOrdersList()
            util.ctl('Vehicles').vehicles = response.vehicles
            util.ctl('Vehicles').loadVehiclesList()
            localStorage['purpleReferralReferredValue'] = response.system.referral_referred_value
            localStorage['purpleReferralReferrerGallons'] = response.system.referral_referrer_gallons
            @renderPaymentMethodsList @paymentMethods
          else
            util.alert response.message, "Error", (->)
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          console.log response
  
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
        label: "#{p.brand} *#{p.last4}"
        labelWidth: '100%'
        cls: [
          'bottom-margin'
          'click-to-edit'
        ]
        disabled: yes
        listeners:
          initialize: (field) =>
            field.element.on 'tap', =>
              pmid = field.getId().substring 5
              util.confirmDialog "",
                ((index) => switch index
                  when 1 then @askToDeleteCard pmid
                  when 2 then @makeDefault pmid
                  else return
                ),
                field.getLabel(),
                ["Delete Card", "Make Default", "Cancel"]

  askToDeleteCard: (id) ->
    util.confirm(
      '',
      "Are you sure you want to delete this card?",
      (=> @deleteCard id),
      null,
      'Delete Card',
      'Cancel'
    )
    
  deleteCard: (id) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/edit"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        card:
          id: id
          action: 'delete'
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @paymentMethods = response.cards
          delete localStorage['purpleDefaultPaymentMethodId']
          for c, card of response.cards
            if card.default
              localStorage['purpleDefaultPaymentMethodId'] = card.id
              localStorage['purpleDefaultPaymentMethodDisplayText'] = """
                #{card.brand} *#{card.last4}
              """
          @refreshPaymentMethodField()
          util.ctl('Vehicles').vehicles = response.vehicles
          util.ctl('Orders').orders = response.orders
          @renderPaymentMethodsList @paymentMethods
        else
          util.alert response.message, "Error", (->)
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response
        
  makeDefault: (id) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/edit"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        card:
          id: id
          action: 'makeDefault'
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @paymentMethods = response.cards
          delete localStorage['purpleDefaultPaymentMethodId']
          for c, card of response.cards
            if card.default
              localStorage['purpleDefaultPaymentMethodId'] = card.id
              localStorage['purpleDefaultPaymentMethodDisplayText'] = """
                #{card.brand} *#{card.last4}
              """
          @refreshPaymentMethodField()
          @renderPaymentMethodsList @paymentMethods
          util.ctl('Menu').popOffBackButtonWithoutAction()
          @backToPreviousPage()
        else
          util.alert response.message, "Error", (->)
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  saveChanges: (callback) ->
    values = @getEditPaymentMethodForm().getValues()
    values['card_number'] = values['card_number'].replace(/[^\d]/gi, '')
    card =
      number: values['card_number']
      cvc: values['card_cvc']
      exp_month: values['card_exp_month']
      exp_year: values['card_exp_year']
      address_zip: "" + values['card_billing_zip']

    for f, field of card
      if field is ""
        util.alert "All fields are required.", "Error", (->)
        return

    Stripe.setPublishableKey util.STRIPE_PUBLISHABLE_KEY
    paymentMethodId = @getEditPaymentMethodForm().config.paymentMethodId
    values['id'] = paymentMethodId
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
      
    Stripe.card.createToken card, (status, response) =>
      if response.error
        Ext.Viewport.setMasked false
        util.alert response.error.message, "Error", (->)
      else
        stripe_token = response.id    
        Ext.Ajax.request
          url: "#{util.WEB_SERVICE_BASE_URL}user/edit"
          params: Ext.JSON.encode
            version: util.VERSION_NUMBER
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
              @paymentMethods = response.cards
              delete localStorage['purpleDefaultPaymentMethodId']
              for c, card of response.cards
                if card.default
                  localStorage['purpleDefaultPaymentMethodId'] = card.id
                  localStorage['purpleDefaultPaymentMethodDisplayText'] = """
                    #{card.brand} *#{card.last4}
                  """
              @refreshPaymentMethodField()
              util.ctl('Vehicles').vehicles = response.vehicles
              util.ctl('Orders').orders = response.orders
              @renderPaymentMethodsList @paymentMethods
              util.ctl('Menu').popOffBackButtonWithoutAction()
              @backToPaymentMethods()
              if typeof callback is 'function'
                callback()
              else
                util.ctl('Menu').popOffBackButtonWithoutAction()
                @backToPreviousPage()
            else
              util.alert response.message, "Error", (->)
          failure: (response_obj) ->
            Ext.Viewport.setMasked false
            response = Ext.JSON.decode response_obj.responseText
            console.log response

  initAccountPaymentMethodField: (field) ->
    @refreshPaymentMethodField()
    field.element.on 'tap', =>
      @paymentMethodFieldTap()

  refreshPaymentMethodField: ->
    @getAccountPaymentMethodField()?.setValue "Add a Card"
    @getPaymentMethodConfirmationField()?.setValue "Add a Card"

    if localStorage['purpleDefaultPaymentMethodId']? and
    localStorage['purpleDefaultPaymentMethodId'] isnt ''
      if @paymentMethods?
        for c, card of @paymentMethods
          if card.default
            if card.id isnt localStorage['purpleDefaultPaymentMethodId']
              # this shouldn't happen, something is out of sync
              alert "Error #289"
            localStorage['purpleDefaultPaymentMethodDisplayText'] = """
              #{card.brand} *#{card.last4}
            """
            @getAccountPaymentMethodField()?.setValue(
              localStorage['purpleDefaultPaymentMethodDisplayText']
            )
            @getPaymentMethodConfirmationField()?.setValue(
              localStorage['purpleDefaultPaymentMethodDisplayText']
            )
            break
      else if localStorage['purpleDefaultPaymentMethodDisplayText']? and
      localStorage['purpleDefaultPaymentMethodDisplayText'] isnt '' 
        @getAccountPaymentMethodField()?.setValue(
          localStorage['purpleDefaultPaymentMethodDisplayText']
        )
        @getPaymentMethodConfirmationField()?.setValue(
          localStorage['purpleDefaultPaymentMethodDisplayText']
        )

  paymentMethodFieldTap: (suppressBackButtonBehavior = no, requestGasTabActive = no) ->
    @requestGasTabActive = requestGasTabActive

    if @requestGasTabActive
      @getRequestGasTabContainer().setActiveItem(
        Ext.create 'Purple.view.PaymentMethods'
      )
      if not suppressBackButtonBehavior
        util.ctl('Menu').pushOntoBackButton =>
          @backToPreviousPage()
    else 
      @getAccountTabContainer().setActiveItem(
        Ext.create 'Purple.view.PaymentMethods'
      )
      if not suppressBackButtonBehavior
        util.ctl('Menu').pushOntoBackButton =>
          @backToPreviousPage()

  initEditPaymentMethodFormMonth: ->
    month = (new Date().getMonth() + 1).toString()
    @getEditPaymentMethodFormMonth().setValue month

  initEditPaymentMethodFormYear: ->
    year = (new Date().getFullYear()).toString()
    @getEditPaymentMethodFormYear().setValue year

  accountPaymentMethodFieldTap: (suppressBackButtonBehavior = no) ->
    @getAccountTabContainer().setActiveItem(
      Ext.create 'Purple.view.PaymentMethods'
    )
    if not suppressBackButtonBehavior
      util.ctl('Menu').pushOntoBackButton =>
        @backToAccount()

  focusEditPaymentMethodFormBillingZip: (comp, e, eopts) ->
    if Ext.os.name is 'Android' and @scrollToField
      @scrollToField = false
      ost = comp.element.dom.offsetTop - 25
      setTimeout (=>
        @getEditPaymentMethodForm().getScrollable().getScroller().scrollTo 0, ost
        @scrollToField = true
        ), 500
