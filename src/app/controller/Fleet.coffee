Ext.define 'Purple.controller.Fleet',
  extend: 'Ext.app.Controller'
  config:
    refs:
      fleet: 'fleet'
      addFleetOrderFormHeading: '[ctype=addFleetOrderFormHeading]'
      addFleetOrderButtonContainer: '[ctype=addFleetOrderButtonContainer]'
      cancelEditFleetOrderButtonContainer: '[ctype=cancelEditFleetOrderButtonContainer]'
      sendSavedDeliveriesButtonContainer: '[ctype=sendSavedDeliveriesButtonContainer]'
      scanVinBarcodeButtonContainer: '[ctype=scanVinBarcodeButtonContainer]'
      fleetAccountSelectField: '[ctype=fleetAccountSelectField]'
      fleetVinField: '[ctype=fleetVinField]'
      fleetLicensePlateField: '[ctype=fleetLicensePlateField]'
      fleetGallonsField: '[ctype=fleetGallonsField]'
      fleetGasTypeSelectField: '[ctype=fleetGasTypeSelectField]'
      fleetIsTopTierField: '[ctype=fleetIsTopTierField]'
      deliveriesList: '[ctype=deliveriesList]'
    control:
      fleet:
        initialize: 'doInitialize'
      addFleetOrderButtonContainer:
        addFleetOrder: 'addFleetOrder'
      cancelEditFleetOrderButtonContainer:
        cancelEditFleetOrder: 'cancelEditFleetOrder'
      scanVinBarcodeButtonContainer:
        scanBarcode: 'scanBarcode'
      fleetAccountSelectField:
        fleetAccountSelectFieldChange: 'fleetAccountSelectFieldChange'

  launch: ->

  doInitialize: ->
    @getAccounts()
    
  getAccounts: ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}fleet/get-accounts"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        os: Ext.os.name # just an additional info
        lat: util.ctl('Main').lat
        lng: util.ctl('Main').lng
      headers:
        'Content-Type': 'application/json'
      timeout: 15000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          localStorage['purpleFleetAccounts'] = JSON.stringify response.accounts
          localStorage['purpleDefaultFleetAccount'] = response.default_account_id
          @initFleetAccountSelectField()
        else
          @initFleetAccountSelectField()
          util.alert response.message, "Error", (->)
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        @initFleetAccountSelectField()

  initFleetAccountSelectField: ->
    localStorage['purpleFleetAccounts'] ?= "[]"
    localStorage['purpleDefaultFleetAccount'] ?= ""
    accounts = JSON.parse localStorage['purpleFleetAccounts']
    opts = []
    for b,a of accounts
      opts.push
        text: "#{a.name}"
        value: "#{a.id}"
    @getFleetAccountSelectField().setOptions opts
    @getFleetAccountSelectField().setValue(
      localStorage['purpleDefaultFleetAccount']
    )
    @getFleetAccountSelectField().setDisabled no

  fleetAccountSelectFieldChange: ->
    if not @editingId?
      @loadDeliveriesList()
    
  addFleetOrder: ->
    values = @getFleet().getValues()
    if values['gallons'] is "" or values['gallons'] <= 0
      util.alert "'Gallons' must be a number greater than 0.", "Error", (->)
    else if values['vin'] is "" and values['license_plate'] is ""
      util.alert "You must enter either a VIN or License Plate / Stock #.", "Error", (->)
    else
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      formData =
        id: "local" + Math.floor(Math.random() * 999999999)
        user_id: localStorage['purpleUserId']
        account_id: @getFleetAccountSelectField().getValue()
        vin: values['vin']
        license_plate: values['license_plate'].toUpperCase()
        gallons: values['gallons']
        gas_type: values['gas_type']
        is_top_tier: values['is_top_tier']
        timestamp_recorded: Math.floor(Date.now() / 1000)
      if @editingId
        @saveFleetDelivery formData, @editingId
      else
        params = JSON.parse JSON.stringify(formData) # copy
        params.version = util.VERSION_NUMBER
        params.token = localStorage['purpleToken']
        params.os = Ext.os.name
        Ext.Ajax.request
          url: "#{util.WEB_SERVICE_BASE_URL}fleet/add-delivery"
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
              @getFleetVinField().reset()
              @getFleetLicensePlateField().reset()
              @getFleetGallonsField().reset()
              util.alert "Fleet Delivery Added!", "Success", (->)
              @renderDeliveriesList response.deliveries
            else
              util.alert response.message, "Error", (->)
          failure: (response_obj) ->
            Ext.Viewport.setMasked false
            util.confirm(
              "Save delivery details for later?",
              "Unable to Connect",
              (=>
                localStorage['purpleSavedFleetDeliveries'] ?= "[]"
                savedDeliveries = JSON.parse localStorage['purpleSavedFleetDeliveries']
                formData.savedLocally = true
                savedDeliveries.push formData
                localStorage['purpleSavedFleetDeliveries'] = JSON.stringify savedDeliveries
                @getFleetVinField().reset()
                @getFleetLicensePlateField().reset()
                @getFleetGallonsField().reset()
                @renderDeliveriesList()))

  sendSavedDeliveries: ->
    fleetLocationId = @getFleetAccountSelectField().getValue()
    localStorage['purpleSavedFleetDeliveries'] ?= "[]"
    allSavedDeliveries = JSON.parse localStorage['purpleSavedFleetDeliveries']
    savedDeliveries = allSavedDeliveries.filter(
      (x) => (x.account_id is fleetLocationId)
    )
    if savedDeliveries.length
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}fleet/add-deliveries"
        params: Ext.JSON.encode
          version: util.VERSION_NUMBER
          user_id: localStorage['purpleUserId']
          token: localStorage['purpleToken']
          os: Ext.os.name
          fleet_location_id: fleetLocationId
          deliveries: savedDeliveries
        headers:
          'Content-Type': 'application/json'
        timeout: 15000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            util.alert "#{savedDeliveries.length} fleet deliveries added!", "Success", (->)
            remainingSavedDeliveries = allSavedDeliveries.filter(
              (x) => (x.account_id isnt fleetLocationId)
            )
            localStorage['purpleSavedFleetDeliveries'] = JSON.stringify remainingSavedDeliveries
            @renderDeliveriesList response.deliveries
          else
            util.alert response.message, "Error", (->)
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          util.alert "Saved deliveries not sent. Still saved for when you have a connection.", "Unable to Connect", (->)
    else
      util.alert "No saved deliveries.", "Error", (->)
    
  scanBarcode: ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    cordova.plugins.barcodeScanner.scan ((result) =>
      # alert("We got a barcode\n" +
      #           "Result: " + result.text + "\n" +
      #           "Format: " + result.format + "\n" +
      #           "Cancelled: " + result.cancelled);
      if not result.cancelled
        @getFleetVinField().setValue result.text.substr(-17)
      else
        alert "Not sure if actually a VIN number."
      Ext.Viewport.setMasked false
    ), ((error) =>
      alert 'Scanning failed: ' + error
      Ext.Viewport.setMasked false
    ), {
      'preferFrontCamera': false
      'showFlipCameraButton': false
      'prompt': 'Place a barcode inside the scan area'
      #'formats': 'CODE_128'
      'formats': 'DATA_MATRIX,CODE_128,CODE_39,QR_CODE'
      'orientation': 'portrait' # todo: only works on Android, problematic in iOS because you often have to tilt the app to see inside of car door
    }

  loadDeliveriesList: ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    # recent remote orders 
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}fleet/get-deliveries"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        os: Ext.os.name # just an additional info
        fleet_location_id: @getFleetAccountSelectField().getValue()
      headers:
        'Content-Type': 'application/json'
      timeout: 7000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @renderDeliveriesList response.deliveries
        else
          util.alert response.message, "Error", (->)
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        @renderDeliveriesList()

  renderDeliveriesList: (deliveries) ->
    # prepend with locally stored deliveries
    localStorage['purpleSavedFleetDeliveries'] ?= "[]"
    allSavedDeliveries = JSON.parse localStorage['purpleSavedFleetDeliveries']
    savedDeliveries = allSavedDeliveries.filter(
      (x) => (x.account_id is @getFleetAccountSelectField().getValue())
    ).sort (a, b) -> b.timestamp_recorded - a.timestamp_recorded
    if deliveries?
      onlyShowLocal = false
      deliveries = savedDeliveries.concat deliveries
    else
      onlyShowLocal = true
      deliveries = savedDeliveries
    @currShowingDeliveries = deliveries
    list =  @getDeliveriesList()
    if not list?
      return
    list.removeAll yes, yes
    if deliveries.length is 0
      list.add
        xtype: 'component'
        flex: 0
        html: """
          No deliveries at this location.
        """
        cls: "loose-text"
        style: "text-align: center;"
    else
      if savedDeliveries.length
        list.add
          xtype: 'container'
          ctype: 'sendSavedDeliveriesButtonContainer'
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
              text: 'Send Saved Deliveries'
              flex: 0
              handler: => @sendSavedDeliveries()
            }
          ]
      list.add
        xtype: 'component'
        flex: 0
        style:
          color: '#555555'
          fontSize: '14px'
        html: 'Tap on a delivery to edit or delete.'
      for o in deliveries
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
              )} - #{o.license_plate} #{o.model ? ""}
            </span>
            <br /><span class="subtext">
              #{o.gallons} gal #{if o.vin then "- " + o.vin else ""}
            </span>
          """
          labelWidth: '100%'
          cls: cls
          disabled: yes
          listeners:
            painted: ((o)=>((field) =>
              # todo -this method will cause a slight flicker for cancelled orders
              field.addCls "status-#{o.status}"))(o)
            initialize: (field) =>
              field.element.on 'tap', =>
                oid = field.getId().split('_')[1]
                field.addCls 'order-edit-mode'
                setTimeout (=>
                  delivery = @getDeliveryObject oid
                  util.confirmDialog "",
                    ((index) => switch index
                      when 1
                        @askDeleteFleetDelivery oid, (oid.substring(0, 5) is "local")
                        field.removeCls 'order-edit-mode'
                      when 2
                        @editFleetDelivery oid, (oid.substring(0, 5) is "local")
                        field.removeCls 'order-edit-mode'
                      else
                        field.removeCls 'order-edit-mode'
                    ),
                    Ext.util.Format.date(
                      new Date(
                        if delivery.timestamp_recorded?
                          delivery.timestamp_recorded * 1000
                        else
                          delivery.timestamp_created
                      ),
                      "n/j g:i a"
                    ),
                    ["Delete Delivery",
                    "Edit Delivery",
                    "Cancel"]
                  ), 100 # wait for UI to update

  # get the delivery details of an order that is currently showing in the deliveries list
  # can be local or remote
  getDeliveryObject: (id) ->
    @currShowingDeliveries.filter(
      (x) -> (x.id is id)
    )[0]
    
  editFleetDelivery: (id, isLocal) ->
    @editingId = id
    delivery = @getDeliveryObject id
    # change title
    @defaultAddFleetOrderFormHeading = @getAddFleetOrderFormHeading().getHtml()
    @getAddFleetOrderFormHeading().setHtml "Edit Fleet Delivery"
    # change submit button text
    @defaultAddFleetOrderButtonContainer =
      @getAddFleetOrderButtonContainer().getAt(0).getText()
    @getAddFleetOrderButtonContainer().getAt(0).setText "Save Changes"
    @getCancelEditFleetOrderButtonContainer().setHidden false
    @getFleet().getScrollable().getScroller().scrollTo 'top', 0
    @getDeliveriesList().setHidden true
    # populate form fields
    @getFleetVinField().setValue delivery['vin']
    @getFleetLicensePlateField().setValue delivery['license_plate']
    @getFleetGallonsField().setValue delivery['gallons']
    @getFleetGasTypeSelectField().setValue delivery['gas_type']
    @getFleetIsTopTierField().setValue delivery['is_top_tier']
    # add logic branch in addFleetOrder for @isEditing
    #
    # 

  exitEditMode: ->
    @editingId = null
    @getAddFleetOrderFormHeading().setHtml @defaultAddFleetOrderFormHeading
    @getAddFleetOrderButtonContainer().getAt(0).setText(
      @defaultAddFleetOrderButtonContainer
    )
    @getFleetVinField().reset()
    @getFleetLicensePlateField().reset()
    @getFleetGallonsField().reset()
    @getCancelEditFleetOrderButtonContainer().setHidden true
    @getDeliveriesList().setHidden false

  saveFleetDelivery: (formData, id) ->
    delivery = @getDeliveryObject id
    # keep old id and timestamp_recorded
    formData.id = id
    formData.timestamp_recorded = delivery.timestamp_recorded
    if delivery.savedLocally
      console.log "update fleet delivery detials locally"
      savedDeliveries = JSON.parse localStorage['purpleSavedFleetDeliveries']
      # savedDeliveriesWithThisOneRemoved
      sdwtor = savedDeliveries.filter(
        (x) -> (x.id isnt id)
      )
      formData.savedLocally = true
      sdwtor.push formData
      localStorage['purpleSavedFleetDeliveries'] = JSON.stringify sdwtor
      @exitEditMode()
      @renderDeliveriesList() # consider doing a loadOrderslist here instead, if online
      Ext.Viewport.setMasked false
      util.alert "Fleet Delivery changes saved!", "Success", (->)
    else
      console.log "update fleet delivery detials remotely"
      params = JSON.parse JSON.stringify(formData) # copy
      params.version = util.VERSION_NUMBER
      params.token = localStorage['purpleToken']
      params.os = Ext.os.name
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}fleet/edit-delivery"
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
            util.alert "Fleet Delivery changes saved!", "Success", (->)
            @renderDeliveriesList response.deliveries
          else
            util.alert response.message, "Error", (->)
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          util.alert "No internet connection.", "Unable to Connect", (->)

  cancelEditFleetOrder: ->
    @exitEditMode()

  askDeleteFleetDelivery: (id, isLocal) ->
    util.confirm(
      "Are you sure you want to delete this delivery permanently?",
      'Confirm',
      (=> @doDeleteFleetDelivery id, isLocal),
      null,
      'Yes',
      'No'
    )

  doDeleteFleetDelivery: (id, isLocal) ->
    if isLocal
      allSavedDeliveries = JSON.parse localStorage['purpleSavedFleetDeliveries']
      savedDeliveries = allSavedDeliveries.filter(
        (x) => (x.id isnt id)
      )
      localStorage['purpleSavedFleetDeliveries'] = JSON.stringify savedDeliveries
      @renderDeliveriesList()
    else
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}fleet/delete-delivery"
        params: Ext.JSON.encode
          version: util.VERSION_NUMBER
          user_id: localStorage['purpleUserId']
          token: localStorage['purpleToken']
          os: Ext.os.name # just an additional info
          fleet_location_id: @getFleetAccountSelectField().getValue()
          delivery_id: id
        headers:
          'Content-Type': 'application/json'
        timeout: 30000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            @renderDeliveriesList response.deliveries
          else
            util.alert response.message, "Error", (->)
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          util.alert "No internet connection.", "Unable to Connect", (->)
          # response = Ext.JSON.decode response_obj.responseText
          # console.log response
