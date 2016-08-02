Ext.define 'Purple.controller.Fleet',
  extend: 'Ext.app.Controller'
  config:
    refs:
      fleet: 'fleet'
      addFleetOrderButtonContainer: '[ctype=addFleetOrderButtonContainer]'
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
          @initFleetAccountSelectField response.accounts, response.default_account_id
        else
          util.alert response.message, "Error", (->)
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  initFleetAccountSelectField: (accounts, defaultAccountId) ->
    opts = []
    for b,a of accounts
      opts.push
        text: "#{a.name}"
        value: "#{a.id}"
    @getFleetAccountSelectField().setOptions opts
    @getFleetAccountSelectField().setValue defaultAccountId
    @getFleetAccountSelectField().setDisabled no
    
  addFleetOrder: ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    values = @getFleet().getValues()
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
          "Send delivery details as a text message?",
          "Unable to Connect",
          (=>
            plugins?.socialsharing?.shareViaSMS(
              encodeURIComponent(JSON.stringify(formData)),
              "3239243338",
              (=>
                @getFleetVinField().reset()
                @getFleetLicensePlateField().reset()
                @getFleetGallonsField().reset()),
              (->)
            ))
        )
        response = Ext.JSON.decode response_obj.responseText
        console.log response
    
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
