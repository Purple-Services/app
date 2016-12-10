Ext.define 'Purple.controller.Fleet',
  extend: 'Ext.app.Controller'
  config:
    refs:
      fleet: 'fleet'
      addFleetOrderButtonContainer: '[ctype=addFleetOrderButtonContainer]'
      sendSavedDeliveriesButtonContainer: '[ctype=sendSavedDeliveriesButtonContainer]'
      scanVinBarcodeButtonContainer: '[ctype=scanVinBarcodeButtonContainer]'
      fleetAccountSelectField: '[ctype=fleetAccountSelectField]'
      fleetVinField: '[ctype=fleetVinField]'
      fleetLicensePlateField: '[ctype=fleetLicensePlateField]'
      fleetGallonsField: '[ctype=fleetGallonsField]'
    control:
      fleet:
        initialize: 'getAccounts'
      addFleetOrderButtonContainer:
        addFleetOrder: 'addFleetOrder'
      sendSavedDeliveriesButtonContainer:  
        sendSavedDeliveries: 'sendSavedDeliveries'
      scanVinBarcodeButtonContainer:
        scanBarcode: 'scanBarcode'

  launch: ->

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
      timeout: 30000
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
        response = Ext.JSON.decode response_obj.responseText
        console.log response

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
    
  addFleetOrder: ->
    values = @getFleet().getValues()
    if values['gallons'] is "" or values['gallons'] is 0
      util.alert "'Gallons' cannot be blank.", "Error", (->)
    else
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      formData =
        user_id: localStorage['purpleUserId']
        account_id: values['account_id']
        vin: values['vin']
        license_plate: values['license_plate']
        gallons: values['gallons']
        gas_type: values['gas_type']
        is_top_tier: values['is_top_tier']
      params = JSON.parse JSON.stringify(formData) # copy
      params.version = util.VERSION_NUMBER
      params.token = localStorage['purpleToken']
      params.os = Ext.os.name
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}fleet/add-delivery"
        params: Ext.JSON.encode params
        headers:
          'Content-Type': 'application/json'
        timeout: 7000
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
              savedDeliveries.push formData
              localStorage['purpleSavedFleetDeliveries'] = JSON.stringify savedDeliveries
              @getFleetVinField().reset()
              @getFleetLicensePlateField().reset()
              @getFleetGallonsField().reset()))
          response = Ext.JSON.decode response_obj.responseText
          console.log response

  sendSavedDeliveries: ->
    localStorage['purpleSavedFleetDeliveries'] ?= "[]"
    savedDeliveries = JSON.parse localStorage['purpleSavedFleetDeliveries']
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
          deliveries: savedDeliveries
        headers:
          'Content-Type': 'application/json'
        timeout: 30000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            util.alert "#{savedDeliveries.length} fleet deliveries added!", "Success", (->)
            localStorage['purpleSavedFleetDeliveries'] = "[]"
          else
            util.alert response.message, "Error", (->)
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          util.alert "Saved deliveries not sent. Still saved for when you have a connection.", "Unable to Connect", (->)
          response = Ext.JSON.decode response_obj.responseText
          console.log response
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
