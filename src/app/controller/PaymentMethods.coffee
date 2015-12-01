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
      paymentMethods: 'paymentmethods' # the PaymentMethods *page*
      paymentMethodsList: '[ctype=paymentMethodsList]'
      editPaymentMethodForm: 'editpaymentmethodform'
      editPaymentMethodFormHeading: '[ctype=editPaymentMethodFormHeading]'
      backToPaymentMethodsButton: '[ctype=backToPaymentMethodsButton]'
      accountPaymentMethodField: '#accountPaymentMethodField'
    control:
      paymentMethods:
        editPaymentMethod: 'showEditPaymentMethodForm'
        loadPaymentMethodsList: 'loadPaymentMethodsList'
        backToAccount: 'backToAccount'
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

  showEditPaymentMethodForm: (paymentMethodId = 'new', suppressBackButtonBehavior = no) ->
    # the way we have things set up, paymentMethodId is always 'new'
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
    @getAccountTabContainer().setActiveItem @getPaymentMethods()
    @getAccountTabContainer().remove(
      @getEditPaymentMethodForm(),
      yes
    )

  backToAccount: ->
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
            @refreshAccountPaymentMethodField()
            util.ctl('Orders').orders = response.orders
            util.ctl('Orders').loadOrdersList()
            util.ctl('Vehicles').vehicles = response.vehicles
            util.ctl('Vehicles').loadVehiclesList()
            localStorage['purpleReferralReferredValue'] = response.system.referral_referred_value
            localStorage['purpleReferralReferrerGallons'] = response.system.referral_referrer_gallons
            @renderPaymentMethodsList @paymentMethods
          else
            navigator.notification.alert response.message, (->), "Error"
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
              navigator.notification.confirm(
                "",
                ((index) => switch index
                  when 1 then @askToDeleteCard pmid
                  when 2 then @makeDefault pmid
                  else return
                ),
                "#{p.brand} *#{p.last4}",
                ["Delete Card", "Make Default", "Cancel"]
              )
              #@showEditPaymentMethodForm pmid

  askToDeleteCard: (id) ->
    navigator.notification.confirm(
      "",
      ((index) => switch index
        when 1 then @deleteCard id
        else return
      ),
      "Are you sure you want to delete this card?",
      ["Delete Card", "Cancel"]
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
          @refreshAccountPaymentMethodField()
          util.ctl('Vehicles').vehicles = response.vehicles
          util.ctl('Orders').orders = response.orders
          @renderPaymentMethodsList @paymentMethods
        else
          navigator.notification.alert response.message, (->), "Error"
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
          @refreshAccountPaymentMethodField()
          @backToAccount()
          @renderPaymentMethodsList @paymentMethods
          util.ctl('Menu').popOffBackButtonWithoutAction()
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  saveChanges: (callback) ->
    values = @getEditPaymentMethodForm().getValues()
    card =
      number: values['card_number']
      cvc: values['card_cvc']
      exp_month: values['card_exp_month']
      exp_year: values['card_exp_year']
      address_zip: "" + values['card_billing_zip']

    for f, field of card
      if field is ""
        navigator.notification.alert "All fields are required.", (->), "Error"
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
        navigator.notification.alert response.error.message, (->), "Error"
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
              @refreshAccountPaymentMethodField()
              util.ctl('Vehicles').vehicles = response.vehicles
              util.ctl('Orders').orders = response.orders
              @backToPaymentMethods()
              @renderPaymentMethodsList @paymentMethods
              util.ctl('Menu').popOffBackButtonWithoutAction()
              if typeof callback is 'function'
                callback()
              else
                util.ctl('Menu').popOffBackButtonWithoutAction()
                @backToAccount()
            else
              navigator.notification.alert response.message, (->), "Error"
          failure: (response_obj) ->
            Ext.Viewport.setMasked false
            response = Ext.JSON.decode response_obj.responseText
            console.log response

  refreshAccountPaymentMethodField: ->
    @getAccountPaymentMethodField()?.setValue "Add a Card"
    
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
            break
      else if localStorage['purpleDefaultPaymentMethodDisplayText']? and
      localStorage['purpleDefaultPaymentMethodDisplayText'] isnt ''  
        @getAccountPaymentMethodField()?.setValue(
          localStorage['purpleDefaultPaymentMethodDisplayText']
        )

  initAccountPaymentMethodField: (field) ->
    @refreshAccountPaymentMethodField()
    field.element.on 'tap', =>
      @accountPaymentMethodFieldTap()

  accountPaymentMethodFieldTap: (suppressBackButtonBehavior = no) ->
    @getAccountTabContainer().setActiveItem(
      Ext.create 'Purple.view.PaymentMethods'
    )
    if not suppressBackButtonBehavior
      util.ctl('Menu').pushOntoBackButton =>
        @backToAccount()
