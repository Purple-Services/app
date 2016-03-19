Ext.define 'Purple.controller.Vehicles',
  extend: 'Ext.app.Controller'
  requires: [
    'Purple.view.EditVehicleForm'
  ]
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      vehiclesTabContainer: '#vehiclesTabContainer'
      vehicles: 'vehicles' # the Vehicles *page*
      vehiclesList: '[ctype=vehiclesList]'
      editVehicleForm: 'editvehicleform'
      editVehicleFormHeading: '[ctype=editVehicleFormHeading]'
      backToVehiclesButton: '[ctype=backToVehiclesButton]'
      editVehicleFormYear: '[ctype=editVehicleFormYear]'
      editVehicleFormMake: '[ctype=editVehicleFormMake]'
      editVehicleFormModel: '[ctype=editVehicleFormModel]'
      editVehicleFormColor: '[ctype=editVehicleFormColor]'
      editVehicleFormGasType: '[ctype=editVehicleFormGasType]'
      editVehicleFormLicensePlate: '[ctype=editVehicleFormLicensePlate]'
      editVehicleFormPhoto: '[ctype=editVehicleFormPhoto]'
      editVehicleFormTakePhotoButton: '[ctype=editVehicleFormTakePhotoButton]'
      requestForm: 'requestform'
      requestFormVehicleSelect: '[ctype=requestFormVehicleSelect]'
      requestFormGallonsSelect: '[ctype=requestFormGallonsSelect]'
      requestFormTimeSelect: '[ctype=requestFormTimeSelect]'
      sendRequestButton: '[ctype=sendRequestButton]'
      requestFormSpecialInstructions: '[ctype=requestFormSpecialInstructions]'
    control:
      vehicles:
        editVehicle: 'showEditVehicleForm'
        loadVehiclesList: 'loadVehiclesList'
      editVehicleForm:
        backToVehicles: 'backToVehicles'
        saveChanges: 'saveChanges'
        deleteVehicle: 'askToDeleteVehicle'
      editVehicleFormYear:
        change: 'yearChanged'
      editVehicleFormMake:
        change: 'makeChanged'
      editVehicleFormModel:
        change: 'modelChanged'
      editVehicleFormColor:
        change: 'colorChanged'
      editVehicleFormTakePhotoButton:
        takePhoto: 'addImage'
      requestFormVehicleSelect:
        initialize: 'initRequestFormVehicleSelect'
        change: 'requestFormVehicleSelectChange'
      requestFormSpecialInstructions:
        focus: 'focusRequestFormSpecialInstructions'

  # will be null until they log in
  vehicles: null

  # all possible vehicle options
  vehicleList: window.vehicleList
  colorList: [
    ''
    'White'
    'Black'
    'Silver'
    'Gray'
    'Red'
    'Blue'
    'Brown'
    'Biege'
    'Cream'
    'Yellow'
    'Gold'
    'Green'
    'Pink'
    'Purple'
    'Copper'
    'Camo'
  ]

  launch: ->
    @callParent arguments

  updateVehicleList: (category, text) ->
    year = @getEditVehicleFormYear().getValue()
    make = @getEditVehicleFormMake().getValue()
    if category is 'make' and not @vehicleList[year][text]
      @vehicleList[year][text] = []
      @updateMakeOptions year
      @getEditVehicleFormMake().setValue text
    if category is 'model' and @vehicleList[year][make].indexOf(text) is -1
      @vehicleList[year][make].push text
      @updateModelOptions year, make
      @getEditVehicleFormModel().setValue text
    if category is 'color' and @colorList.indexOf(text) is -1
      @updateColorOptions text
      @getEditVehicleFormColor().setValue text

  updateMakeOptions: (year) ->
    options = @getMakeList(year).map (x) ->
      {
        text: x
        value: x
      }
    options.push text: '', value: ''
    options.sort (a,b) ->
      a.text.localeCompare(b.text)
    @getEditVehicleFormMake().setOptions options
    @getEditVehicleFormMake().addOtherField()

  updateModelOptions: (year, make) ->
    options = @getModelList(year, make).map (x) ->
      {
        text: x
        value: x
      }
    options.push text: '', value: ''
    options.sort (a,b) ->
      a.text.localeCompare(b.text)
    @getEditVehicleFormModel().setOptions options
    @getEditVehicleFormModel().addOtherField()

  updateColorOptions: (text) ->
    @colorList.push text
    @getEditVehicleFormColor().setOptions(
      @getColorList().map (x) ->
        {
          text: x
          value: x
        }
    )
    @getEditVehicleFormColor().addOtherField()

  addSavedVehicles: (vehicle) ->
    if not @vehicleList[vehicle.year][vehicle.make]
      @vehicleList[vehicle.year][vehicle.make] = []
      @updateMakeOptions vehicle.year
    if @vehicleList[vehicle.year][vehicle.make].indexOf(vehicle.model) is -1
      @vehicleList[vehicle.year][vehicle.make].push vehicle.model
      @updateModelOptions vehicle.year, vehicle.make
    if @colorList.indexOf(vehicle.color) is -1
      @updateColorOptions vehicle.color

  getVehicleById: (id) ->
    for v in @vehicles
      if v['id'] is id
        vehicle = v
        break
    return vehicle

  getYearList: ->
    (v for v, vehicle of @vehicleList).sort (a, b) ->
      parseInt(b) - parseInt(a)

  getMakeList: (year) ->
    if @vehicleList[year]?
      v for v, vehicle of @vehicleList[year]
    else
      []

  getModelList: (year, make) ->
    if @vehicleList[year]?[make]?
      v for v in @vehicleList[year][make]
    else
      []
      
  getColorList: ->
    @colorList

  yearChanged: (field, value) ->
    year = @getEditVehicleFormYear().getValue()
    make = @getEditVehicleFormMake().getValue()
    @updateMakeOptions year
    if make
      @updateModelOptions year, make
    if year
      @getEditVehicleFormMake().setDisabled no
    else
      @getEditVehicleFormMake().setDisabled yes
    @getEditVehicleFormMake().addOtherField()


  makeChanged: (field, value) ->
    year = @getEditVehicleFormYear().getValue()
    @updateModelOptions year, value
    @getEditVehicleFormModel().addOtherField()
    if value and value isnt 'Other...'
      @getEditVehicleFormModel().setDisabled no
    else
      @getEditVehicleFormModel().setDisabled yes
    @getEditVehicleFormMake().fieldChange field, value
     
  modelChanged: (field, value) ->
    @getEditVehicleFormModel().fieldChange field, value

  colorChanged: (field, value) ->
    @getEditVehicleFormColor().fieldChange field, value

  showEditVehicleForm: (vehicleId = 'new', suppressBackButtonBehavior = no) ->
    @getVehiclesTabContainer().setActiveItem(
      Ext.create 'Purple.view.EditVehicleForm',
        vehicleId: vehicleId
    )

    @addSavedVehicles v for v in @vehicles

    if not suppressBackButtonBehavior
      util.ctl('Menu').pushOntoBackButton =>
        @backToVehicles()

    @getEditVehicleFormHeading().setHtml(
      if vehicleId is 'new'
        'Add Vehicle'
      else
        'Edit Vehicle'
    )

    options = @getYearList().map (x) ->
      {
        text: x
        value: x
      }
    options.unshift
      text: ''
      value: ''
    @getEditVehicleFormYear().setOptions options
    @getEditVehicleFormYear().setDisabled no
    
    @getEditVehicleFormColor().setOptions(
      @getColorList().map (x) ->
        {
          text: x
          value: x
        }
    )
    @getEditVehicleFormColor().addOtherField()
    @getEditVehicleFormColor().setDisabled no
    
    if vehicleId isnt 'new'
      vehicle = @getVehicleById vehicleId
      @getEditVehicleFormYear().setValue vehicle['year']
      # you would think setValue should fire the change event
      # but it doesn't, so here is a manual call to prepare for
      # setting the make field
      @yearChanged null, vehicle['year']
      @getEditVehicleFormMake().setValue vehicle['make']
      @makeChanged null, vehicle['make']
      @getEditVehicleFormModel().setValue vehicle['model']
      @getEditVehicleFormColor().setValue vehicle['color']
      @getEditVehicleFormGasType().setValue vehicle['gas_type']
      @getEditVehicleFormLicensePlate().setValue vehicle['license_plate']
      if vehicle['photo']? and vehicle['photo'] isnt ''
        @setVehiclePhoto vehicle['photo']

  backToVehicles: ->
    @getVehiclesTabContainer().remove(
      @getEditVehicleForm(),
      yes
    )

  loadVehiclesList: ->
    if @vehicles?
      @renderVehiclesList @vehicles
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
            @vehicles = response.vehicles
            util.ctl('Orders').orders = response.orders
            util.ctl('Orders').loadOrdersList()
            @renderVehiclesList @vehicles
            localStorage['purpleReferralReferredValue'] = response.system.referral_referred_value
            localStorage['purpleReferralReferrerGallons'] = response.system.referral_referrer_gallons
          else
            navigator.notification.alert response.message, (->), "Error"
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          console.log response
  
  renderVehiclesList: (vehicles) ->
    list =  @getVehiclesList()
    if not list?
      return
    list.removeAll yes, yes
    for v in vehicles
      list.add
        xtype: 'textfield'
        id: "vid_#{v.id}"
        flex: 0
        label: """
          <span class="maintext">#{v.year} #{v.make} #{v.model}</span>
          <br /><span class="subtext">#{v.color} / <span class="license-plate">#{v.license_plate}</span></span>
          <span class="vehicle-photo" style="background-image: url('#{v.photo}') !important;"></span>
        """
        labelWidth: '100%'
        cls: [
          'bottom-margin'
          'vehicle-list-item'
        ]
        disabled: yes
        listeners:
          initialize: (field) =>
            field.element.on 'tap', =>
              vid = field.getId().split('_')[1]
              @showEditVehicleForm vid, no

  saveChanges: (callback) ->
    values = @getEditVehicleForm().getValues()
    vehicleId = @getEditVehicleForm().config.vehicleId
    values['id'] = vehicleId
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/edit"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        vehicle: values
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @vehicles = response.vehicles
          util.ctl('Orders').orders = response.orders
          @backToVehicles()
          @renderVehiclesList @vehicles
          if typeof callback is 'function'
            # this is branching back to where we wanted to create a new vehicle
            # (usually from the Request Form)
            # so, we're going to need the id of the new vehicle
            # most recent creation should be sufficient for our needs
            temp_arr = @vehicles.slice 0
            temp_arr.sort (a, b) ->
              (new Date(b.timestamp_created)) - (new Date(a.timestamp_created))
            callback temp_arr[0].id
          else
            util.ctl('Menu').popOffBackButtonWithoutAction()
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  askToDeleteVehicle: (id) ->
    navigator.notification.confirm(
      "",
      ((index) => switch index
        when 1 then @deleteVehicle id
        else return
      ),
      "Are you sure you want to delete this vehicle?",
      ["Delete Vehicle", "Cancel"]
    )

  deleteVehicle: (vehicleId) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/edit"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        vehicle:
          id: vehicleId
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
          @vehicles = response.vehicles
          util.ctl('Orders').orders = response.orders
          @backToVehicles()
          @renderVehiclesList @vehicles
          util.ctl('Menu').popOffBackButtonWithoutAction()
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  initRequestFormVehicleSelect: ->
    if @vehicles?
      opts = @vehicles.map (v) ->
        {
          text: "#{v.model} (#{v.license_plate.toUpperCase()})"
          value: v.id
        }
      opts.push
        text: "New Vehicle"
        value: 'new'
      @getRequestFormVehicleSelect().setOptions opts
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
            @vehicles = response.vehicles
            util.ctl('Orders').orders = response.orders
            localStorage['purpleReferralReferredValue'] = response.system.referral_referred_value
            localStorage['purpleReferralReferrerGallons'] = response.system.referral_referrer_gallons
            opts = @vehicles.map (v) ->
              {
                text: "#{v.model} (#{v.license_plate.toUpperCase()})"
                value: v.id
              }
            opts.push
              text: "New Vehicle"
              value: 'new'
            @getRequestFormVehicleSelect().setOptions opts
          else
            navigator.notification.alert response.message, (->), "Error"
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          console.log response

  requestFormVehicleSelectChange: (field, value) ->
    if value is 'new'
      util.ctl('Menu').selectOption 4
      @showEditVehicleForm 'new', yes
      @getEditVehicleForm().config.saveChangesCallback = (vehicleId) =>
        util.ctl('Menu').popOffBackButtonWithoutAction()
        util.ctl('Menu').selectOption 0
        @initRequestFormVehicleSelect()
        @getRequestFormVehicleSelect().setValue vehicleId
      util.ctl('Menu').pushOntoBackButton =>
        # to account for the removal of the RequestForm
        util.ctl('Menu').popOffBackButtonWithoutAction()
        @backToVehicles()
        util.ctl('Main').backToMapFromRequestForm()
        util.ctl('Menu').selectOption 0
    else
      ready = @getRequestFormGallonsSelect()? and @getRequestFormTimeSelect()?
      # TODO, make nicer:
      # hacky use of setTimeout, but need to make sure DOM is ready
      setTimeout (=>
        # get the availability option that corresponds with our octane
        gasType = @getVehicleById(value).gas_type
        for a in @getRequestForm().config.availabilities
          if a['octane'] is gasType
            availability = a
            break
            
        # do we have any gas available in that octane?
        if util.ctl('Main').isEmpty availability.gallon_choices
          navigator.notification.alert "Sorry, we are unable to deliver #{availability.octane} Octane to your location at this time.", (->), "Unavailable"
          @getRequestFormGallonsSelect().setDisabled yes
          @getRequestFormTimeSelect().setDisabled yes
          @getSendRequestButton().setDisabled yes
          return

        # populate options for number of gallons
        gallonsOpts = []
        for f,g of availability.gallon_choices
          gallonsOpts.push
            text: "#{g}"
            value: "#{g}"
        @getRequestFormGallonsSelect().setOptions gallonsOpts
        @getRequestFormGallonsSelect().setDisabled no

        # populate the time options
        timeOpts = []
        for t, time of availability.times
          timeOpts.push
            text: time['text']
            value: t
            order: time['order']
        timeOpts.sort (a, b) -> a['order'] - b['order']
        @getRequestFormTimeSelect().setOptions timeOpts
        @getRequestFormTimeSelect().setDisabled no
        
        @getSendRequestButton().setDisabled no
      ), (if ready then 5 else 500)
  
  focusRequestFormSpecialInstructions: ->
    if localStorage['specialInstructions'] and not @specialInstructionsAutoFillPrompted
      @specialInstructionsAutoFillPrompted = true
      navigator.notification.confirm 'Would you like to automatically fill with your previous instructions?', (Ext.bind @specialInstructionsAutoFill, this), 'Auto Fill'

  specialInstructionsAutoFill: (index) ->
    @getRequestFormSpecialInstructions().blur()
    if index is 1
      @getRequestFormSpecialInstructions().setValue localStorage['specialInstructions']

  addImage: ->
    addImageStep2 = Ext.bind @addImageStep2, this

    addImageStep2 Camera.PictureSourceType.CAMERA
    
    # not using this intermediary step right now
    # navigator.notification.confirm(
    #   "",
    #   ((index) => switch index
    #     when 1 then addImageStep2 Camera.PictureSourceType.CAMERA
    #     when 2 then addImageStep2 Camera.PictureSourceType.PHOTOLIBRARY
    #     else return
    #   ),
    #   "Add Vehicle Photo",
    #   ["Take New Photo", "Choose from Photo Library", "Cancel"]
    # )

  addImageStep2: (sourceType) ->
    addImageSuccess = Ext.bind @addImageSuccess, this
    navigator.camera.getPicture addImageSuccess, (->),
      destinationType: Camera.DestinationType.DATA_URL
      quality: 40
      targetWidth: 700
      targetHeight: 700
      correctOrientation: yes      

  addImageSuccess: (dataUrl) ->
    dataUrl = "data:image/jpeg;base64,#{dataUrl}"
    @setVehiclePhoto dataUrl

  setVehiclePhoto: (dataUrl) ->
    @getEditVehicleFormTakePhotoButton().element.dom.style.cssText = """
      background-image: url('#{dataUrl}') !important;
    """
    @getEditVehicleFormPhoto().setValue dataUrl
    analytics?.track 'Took Vehicle Photo'
