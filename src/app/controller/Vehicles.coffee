Ext.define 'Purple.controller.Vehicles'
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
      requestFormVehicleSelect: '[ctype=requestFormVehicleSelect]'
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
      requestFormVehicleSelect:
        initialize: 'initRequestFormVehicleSelect'
        change: 'requestFormVehicleSelectChange'

  # will be null until they log in
  vehicles: null

  # all possible vehicle options
  vehicleList: window.vehicleList
  colorList: [
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
    @getEditVehicleFormMake().setOptions(
      @getMakeList(value).map (x) ->
        {
          text: x
          value: x
        }
    )
    @getEditVehicleFormMake().setDisabled no

  makeChanged: (field, value) ->
    year = @getEditVehicleFormYear().getValue()
    @getEditVehicleFormModel().setOptions(
      @getModelList(year, value).map (x) ->
        {
          text: x
          value: x
        }
    )
    @getEditVehicleFormModel().setDisabled no

  showEditVehicleForm: (vehicleId = 'new') ->
    @getVehiclesTabContainer().setActiveItem(
      Ext.create 'Purple.view.EditVehicleForm',
        vehicleId: vehicleId
    )

    @getEditVehicleFormHeading().setHtml(
      if vehicleId is 'new'
        'Add Vehicle'
      else
        'Edit Vehicle'
    )
    
    @getEditVehicleFormYear().setOptions(
      @getYearList().map (x) ->
        {
          text: x
          value: x
        }
    )
    @getEditVehicleFormYear().setDisabled no
    
    @getEditVehicleFormColor().setOptions(
      @getColorList().map (x) ->
        {
          text: x
          value: x
        }
    )
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
    else
      console.log 'new'
      # @getEditVehicleFormYear().setValue '2015'
      # @yearChanged null, '2015'
      # @getEditVehicleFormMake().setValue ''
      # @getEditVehicleFormMake().setOptions []
      # @getEditVehicleFormModel().setValue ''
      # @getEditVehicleFormModel().setOptions []      

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
          user_id: localStorage['purpleUserId']
          token: localStorage['purpleToken']
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
        label: "#{v.year} #{v.make} #{v.model}"
        labelWidth: '100%'
        cls: [
          'bottom-margin'
        ]
        disabled: yes
        listeners:
          initialize: (field) =>
            field.element.on 'tap', =>
              vid = field.getId().split('_')[1]
              @showEditVehicleForm vid

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
            # so, we're going to need the id of the new vehicle
            # most recent creation should be sufficient for our needs
            temp_arr = @vehicles.slice 0
            temp_arr.sort (a, b) ->
              (new Date(b.timestamp_created)) - (new Date(a.timestamp_created))
            callback temp_arr[0].id
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
          text: "#{v.year} #{v.make} #{v.model}"
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
          user_id: localStorage['purpleUserId']
          token: localStorage['purpleToken']
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
            opts = @vehicles.map (v) ->
              {
                text: "#{v.year} #{v.make} #{v.model}"
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
      @showEditVehicleForm()
      @getEditVehicleForm().config.saveChangesCallback = (vehicleId) =>
        util.ctl('Menu').selectOption 0
        @initRequestFormVehicleSelect()
        @getRequestFormVehicleSelect().setValue vehicleId
      @getBackToVehiclesButton().setHidden yes
