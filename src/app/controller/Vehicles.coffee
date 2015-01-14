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
      vehiclesList: '#vehiclesList'
      editVehicleForm: 'editvehicleform'
    control:
      vehicles:
        editVehicle: 'showEditVehicleForm'
        loadVehiclesList: 'loadVehiclesList'
        backToVehicles: 'backToVehicles'

  # whether or not the inital map centering has occurred yet
  mapInitiallyCenteredYet: no
  mapInited: no

  launch: ->
    @callParent arguments

  showEditVehicleForm: (vehicleId = 'new') ->
    console.log 'edit: ', vehicleId
    @getVehiclesTabContainer().setActiveItem(
      Ext.create 'Purple.view.EditVehicleForm',
        vehicleId: vehicleId
    )

  backToVehicles: ->
    @getVehiclesTabContainer().remove(
      @getVehiclesTabContainer().getActiveItem(),
      yes
    )

  loadVehiclesList: ->
    vehicles = [
      {
        id: '123abc'
        model: 'ES 350'
        make: 'Lexus'
        color: 'silver'
        year: '2012'
        gas_type: '91'
        license_plate: '8U7-631R'
      }
      {
        id: 'fdd'
        model: 'Pilot'
        make: 'Honda'
        color: 'blue'
        year: '2013'
        gas_type: '89'
        license_plate: '123-HGHH'
      }
      {
        id: '99ddh'
        model: 'Civic'
        make: 'Honda'
        color: 'white'
        year: '1995'
        gas_type: '89'
        license_plate: '888-JJKN'
      }
    ]
    @renderVehiclesList vehicles
  
  renderVehiclesList: (vehicles) ->
    list =  @getVehiclesList()
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
