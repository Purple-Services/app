Ext.define 'Purple.controller.GasPurchases',
  extend: 'Ext.app.Controller'
  config:
    refs:
      gasPurchases: 'gaspurchases'
      addGasPurchaseFormHeading: '[ctype=addGasPurchaseFormHeading]'
      addGasPurchaseButtonContainer: '[ctype=addGasPurchaseButtonContainer]'
      cancelEditGasPurchaseButtonContainer: '[ctype=cancelEditGasPurchaseButtonContainer]'
      sendSavedGasPurchasesButtonContainer: '[ctype=sendSavedGasPurchasesButtonContainer]'
      scanVinBarcodeButtonContainer: '[ctype=scanVinBarcodeButtonContainer]'
      gasGallonsField: '[ctype=gasGallonsField]'
      gasGasTypeSelectField: '[ctype=gasGasTypeSelectField]'
      gasGallonsField: '[ctype=gasGallonsField]'
      gasTotalPriceField: '[ctype=gasTotalPriceField]'
      gasPurchasesList: '[ctype=gasPurchasesList]'
    control:
      gaspurchases:
        initialize: 'doInitialize'
      addGasPurchaseButtonContainer:
        addGasPurchase: 'addGasPurchase'
      cancelEditGasPurchaseButtonContainer:
        cancelEditGasPurchase: 'cancelEditGasPurchase'

  launch: ->

  doInitialize: ->
    @loadGasPurchasesList()
      
  addGasPurchase: ->
    values = @getGasPurchases().getValues()
    if values['gallons'] is "" or values['gallons'] <= 0
      util.alert "'Gallons' must be a number greater than 0.", "Error", (->)
    else if values['total_price'] is "" or values['total_price'] <= 0
      util.alert "'Total Price' must be a number greater than 0.", "Error", (->)
    else if (values['total_price'] / values['gallons']) <= 1
      util.alert "Please write the TOTAL price, not the price per gallon.", "Error", (->)
    else
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      formData =
        id: "local" + Math.floor(Math.random() * 999999999)
        user_id: localStorage['purpleUserId']
        gallons: values['gallons']
        gas_type: values['gas_type']
        total_price: values['total_price']
        lat: util.ctl('Main').lat
        lng: util.ctl('Main').lng
        timestamp_recorded: Math.floor(Date.now() / 1000)
      if @editingId
        @saveGasPurchase formData, @editingId
      else
        params = JSON.parse JSON.stringify(formData) # copy
        params.version = util.VERSION_NUMBER
        params.token = localStorage['purpleToken']
        params.os = Ext.os.name
        Ext.Ajax.request
          url: "#{util.WEB_SERVICE_BASE_URL}courier/add-gas-purchase"
          params: Ext.JSON.encode params
          headers:
            'Content-Type': 'application/json'
          timeout: 15000
          method: 'POST'
          scope: this
          success: (response_obj) ->
            Ext.Viewport.setMasked false
            response = Ext.JSON.decode response_obj.responseText
            if response.success
              @getGasGallonsField().reset()
              @getGasTotalPriceField().reset()
              util.alert "Gas Purchase Added!", "Success", (->)
              @renderGasPurchasesList response.gas_purchases
            else
              util.alert response.message, "Error", (->)
          failure: (response_obj) ->
            Ext.Viewport.setMasked false
            util.confirm(
              "Save gas purchase details for later?",
              "Unable to Connect",
              (=>
                localStorage['purpleSavedGasPurchases'] ?= "[]"
                savedGasPurchases = JSON.parse localStorage['purpleSavedGasPurchases']
                formData.savedLocally = true
                # put it in cents
                formData.total_price = "" + formData.total_price
                savedGasPurchases.push formData
                localStorage['purpleSavedGasPurchases'] = JSON.stringify savedGasPurchases
                @getGasGallonsField().reset()
                @getGasTotalPriceField().reset()
                @renderGasPurchasesList()))

  sendSavedGasPurchases: ->
    localStorage['purpleSavedGasPurchases'] ?= "[]"
    savedGasPurchases = JSON.parse localStorage['purpleSavedGasPurchases']
    if savedGasPurchases.length
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}courier/add-gas-purchases"
        params: Ext.JSON.encode
          version: util.VERSION_NUMBER
          user_id: localStorage['purpleUserId']
          token: localStorage['purpleToken']
          os: Ext.os.name
          gas_purchases: savedGasPurchases
        headers:
          'Content-Type': 'application/json'
        timeout: 15000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            util.alert "#{savedGasPurchases.length} gas purchases added!", "Success", (->)
            localStorage['purpleSavedGasPurchases'] = "[]"
            @renderGasPurchasesList response.gas_purchases
          else
            util.alert response.message, "Error", (->)
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          util.alert "Saved gas purchases not sent. Still saved for when you have a connection.", "Unable to Connect", (->)
    else
      util.alert "No saved gas purchases.", "Error", (->)
    
  loadGasPurchasesList: ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    # get recent gas purchases from server
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}courier/get-gas-purchases"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        os: Ext.os.name # just an additional info
      headers:
        'Content-Type': 'application/json'
      timeout: 7000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @renderGasPurchasesList response.gas_purchases
        else
          util.alert response.message, "Error", (->)
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        @renderGasPurchasesList()

  renderGasPurchasesList: (purchases) ->
    # prepend with locally stored gas purchases
    localStorage['purpleSavedGasPurchases'] ?= "[]"
    unsortedSavedGasPurchases = JSON.parse localStorage['purpleSavedGasPurchases']
    savedGasPurchases = unsortedSavedGasPurchases.sort (a, b) -> b.timestamp_recorded - a.timestamp_recorded
    if purchases?
      onlyShowLocal = false
      purchases = savedGasPurchases.concat purchases
    else
      onlyShowLocal = true
      purchases = savedGasPurchases
    @currShowingPurchases = purchases
    list =  @getGasPurchasesList()
    if not list?
      return
    list.removeAll yes, yes
    if purchases.length is 0
      list.add
        xtype: 'component'
        flex: 0
        html: """
          No recent gas purchases.
        """
        cls: "loose-text"
        style: "text-align: center;"
    else
      if savedGasPurchases.length
        list.add
          xtype: 'container'
          ctype: 'sendGasPurchasesButtonContainer'
          flex: 0
          height: 70
          width: '100%'
          padding: '0 0 15 0'
          layout:
            type: 'vbox'
            pack: 'center'
            align: 'center'
          cls: 'smaller-button-pop'
          items: [
            {
              xtype: 'button'
              ui: 'action'
              cls: [
                'button-pop'
                'button-pop-orange'
              ]
              text: 'Send Saved Records'
              flex: 0
              handler: => @sendSavedGasPurchases()
            }
          ]
      list.add
        xtype: 'component'
        flex: 0
        style:
          color: '#555555'
          fontSize: '14px'
        html: 'Tap on a purchase to edit or delete.'
      for o in purchases
        cls = [
          'bottom-margin'
          'order-list-item'
        ]
        if o.savedLocally
          cls.push 'highlighted'
        list.add
          xtype: 'textfield'
          id: "oid_#{o.id}"
          flex: 0
          label: """
            <span>
              #{Ext.util.Format.date(
                new Date(
                  if o.timestamp_recorded?
                    o.timestamp_recorded * 1000
                  else
                    o.timestamp_created
                ),
                "n/j g:i a"
              )} - $#{
                if o.savedLocally
                  o.total_price
                else
                  util.centsToDollars o.total_price
              }
            </span>
            <br /><span class="subtext">
              #{o.gallons} gal of #{o.gas_type}
            </span>
          """
          labelWidth: '100%'
          cls: cls
          disabled: yes
          listeners:
            initialize: (field) =>
              field.element.on 'tap', =>
                oid = field.getId().split('_')[1]
                field.addCls 'order-edit-mode'
                setTimeout (=>
                  purchase = @getPurchaseObject oid
                  util.confirmDialog "",
                    ((index) => switch index
                      when 1
                        @askDeleteGasPurchase oid, (oid.substring(0, 5) is "local")
                        field.removeCls 'order-edit-mode'
                      when 2
                        @editGasPurchase oid, (oid.substring(0, 5) is "local")
                        field.removeCls 'order-edit-mode'
                      else
                        field.removeCls 'order-edit-mode'
                    ),
                    Ext.util.Format.date(
                      new Date(
                        if purchase.timestamp_recorded?
                          purchase.timestamp_recorded * 1000
                        else
                          purchase.timestamp_created
                      ),
                      "n/j g:i a"
                    ),
                    ["Delete Purchase",
                    "Edit Purchase",
                    "Cancel"]
                  ), 100 # wait for UI to update

  # Get the purchase details of a purchase that is currently showing in the
  # gas purchases list. Can be local or remote.
  getPurchaseObject: (id) ->
    @currShowingPurchases.filter(
      (x) -> (x.id is id)
    )[0]
    
  editGasPurchase: (id, isLocal) ->
    @editingId = id
    purchase = @getPurchaseObject id
    # change title
    @defaultAddGasPurchaseFormHeading = @getAddGasPurchaseFormHeading().getHtml()
    @getAddGasPurchaseFormHeading().setHtml "Edit Gas Purchase"
    # change submit button text
    @defaultAddGasPurchaseButtonContainer =
      @getAddGasPurchaseButtonContainer().getAt(0).getText()
    @getAddGasPurchaseButtonContainer().getAt(0).setText "Save Changes"
    @getCancelEditGasPurchaseButtonContainer().setHidden false
    @getGasPurchases().getScrollable().getScroller().scrollTo 'top', 0
    @getGasPurchasesList().setHidden true
    # populate form fields
    @getGasGallonsField().setValue purchase['gallons']
    @getGasGasTypeSelectField().setValue purchase['gas_type']
    @getGasTotalPriceField().setValue (util.centsToDollars purchase['total_price'])

  exitEditMode: ->
    @editingId = null
    @getAddGasPurchaseFormHeading().setHtml @defaultAddGasPurchaseFormHeading
    @getAddGasPurchaseButtonContainer().getAt(0).setText(
      @defaultAddGasPurchaseButtonContainer
    )
    @getGasGallonsField().reset()
    @getGasTotalPriceField().reset()
    @getCancelEditGasPurchaseButtonContainer().setHidden true
    @getGasPurchasesList().setHidden false

  saveGasPurchase: (formData, id) ->
    purchase = @getPurchaseObject id
    # keep old id and timestamp_recorded
    formData.id = id
    formData.timestamp_recorded = purchase.timestamp_recorded
    if purchase.savedLocally
      savedPurchases = JSON.parse localStorage['purpleSavedGasPurchases']
      # savedPurchasesWithThisOneRemoved
      spwtor = savedPurchases.filter(
        (x) -> (x.id isnt id)
      )
      formData.savedLocally = true
      spwtor.push formData
      localStorage['purpleSavedGasPurchases'] = JSON.stringify spwtor
      @exitEditMode()
      @renderGasPurchasesList()
      Ext.Viewport.setMasked false
      util.alert "Gas Purchase changes saved!", "Success", (->)
    else
      params = JSON.parse JSON.stringify(formData) # copy
      params.version = util.VERSION_NUMBER
      params.token = localStorage['purpleToken']
      params.os = Ext.os.name
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}courier/edit-gas-purchase"
        params: Ext.JSON.encode params
        headers:
          'Content-Type': 'application/json'
        timeout: 15000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            @exitEditMode()
            util.alert "Gas purchase changes saved!", "Success", (->)
            @renderGasPurchasesList response.gas_purchases
          else
            util.alert response.message, "Error", (->)
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          util.alert "No internet connection.", "Unable to Connect", (->)

  cancelEditGasPurchase: ->
    @exitEditMode()

  askDeleteGasPurchase: (id, isLocal) ->
    util.confirm(
      "Are you sure you want to delete this gas purchase?",
      'Confirm',
      (=> @doDeleteGasPurchase id, isLocal),
      null,
      'Yes',
      'No'
    )

  doDeleteGasPurchase: (id, isLocal) ->
    if isLocal
      allSavedGasPurchases = JSON.parse localStorage['purpleSavedGasPurchases']
      savedGasPurchases = allSavedGasPurchases.filter(
        (x) => (x.id isnt id)
      )
      localStorage['purpleSavedGasPurchases'] = JSON.stringify savedGasPurchases
      @loadGasPurchasesList()
    else
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}courier/delete-gas-purchase"
        params: Ext.JSON.encode
          version: util.VERSION_NUMBER
          user_id: localStorage['purpleUserId']
          token: localStorage['purpleToken']
          os: Ext.os.name # just an additional info
          id: id
        headers:
          'Content-Type': 'application/json'
        timeout: 30000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            @renderGasPurchasesList response.gas_purchases
          else
            util.alert response.message, "Error", (->)
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          util.alert "No internet connection.", "Unable to Connect", (->)
