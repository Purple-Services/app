// Generated by CoffeeScript 1.3.3

Ext.define('Purple.controller.Vehicles', {
  extend: 'Ext.app.Controller',
  requires: ['Purple.view.EditVehicleForm'],
  config: {
    refs: {
      mainContainer: 'maincontainer',
      topToolbar: 'toptoolbar',
      vehiclesTabContainer: '#vehiclesTabContainer',
      vehicles: 'vehicles',
      vehiclesList: '#vehiclesList',
      editVehicleForm: 'editvehicleform'
    },
    control: {
      vehicles: {
        editVehicle: 'showEditVehicleForm',
        loadVehiclesList: 'loadVehiclesList'
      },
      editVehicleForm: {
        backToVehicles: 'backToVehicles'
      }
    }
  },
  mapInitiallyCenteredYet: false,
  mapInited: false,
  launch: function() {
    return this.callParent(arguments);
  },
  showEditVehicleForm: function(vehicleId) {
    if (vehicleId == null) {
      vehicleId = 'new';
    }
    console.log('edit: ', vehicleId);
    return this.getVehiclesTabContainer().setActiveItem(Ext.create('Purple.view.EditVehicleForm', {
      vehicleId: vehicleId
    }));
  },
  backToVehicles: function() {
    return this.getVehiclesTabContainer().remove(this.getVehiclesTabContainer().getActiveItem(), true);
  },
  loadVehiclesList: function() {
    var vehicles;
    vehicles = [
      {
        id: '123abc',
        model: 'ES 350',
        make: 'Lexus',
        color: 'silver',
        year: '2012',
        gas_type: '91',
        license_plate: '8U7-631R'
      }, {
        id: 'fdd',
        model: 'Pilot',
        make: 'Honda',
        color: 'blue',
        year: '2013',
        gas_type: '89',
        license_plate: '123-HGHH'
      }, {
        id: '99ddh',
        model: 'Civic',
        make: 'Honda',
        color: 'white',
        year: '1995',
        gas_type: '89',
        license_plate: '888-JJKN'
      }
    ];
    return this.renderVehiclesList(vehicles);
  },
  renderVehiclesList: function(vehicles) {
    var list, v, _i, _len, _results,
      _this = this;
    list = this.getVehiclesList();
    _results = [];
    for (_i = 0, _len = vehicles.length; _i < _len; _i++) {
      v = vehicles[_i];
      _results.push(list.add({
        xtype: 'textfield',
        id: "vid_" + v.id,
        flex: 0,
        label: "" + v.year + " " + v.make + " " + v.model,
        labelWidth: '100%',
        cls: ['bottom-margin'],
        disabled: true,
        listeners: {
          initialize: function(field) {
            return field.element.on('tap', function() {
              var vid;
              vid = field.getId().split('_')[1];
              return _this.showEditVehicleForm(vid);
            });
          }
        }
      }));
    }
    return _results;
  }
});