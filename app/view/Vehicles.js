// Generated by CoffeeScript 1.9.3
Ext.define('Purple.view.Vehicles', {
  extend: 'Ext.Container',
  xtype: 'vehicles',
  requires: ['Ext.form.*', 'Ext.field.*', 'Ext.Button'],
  config: {
    layout: {
      type: 'hbox',
      pack: 'start',
      align: 'start'
    },
    height: '100%',
    submitOnAction: false,
    cls: ['request-form', 'accent-bg', 'slideable'],
    scrollable: {
      direction: 'vertical',
      directionLock: true
    },
    listeners: {
      initialize: function() {
        return this.fireEvent('loadVehiclesList');
      }
    },
    items: [
      {
        xtype: 'spacer',
        flex: 1
      }, {
        xtype: 'container',
        flex: 0,
        width: '85%',
        style: 'max-width: 85%;',
        layout: {
          type: 'vbox',
          pack: 'start',
          align: 'start'
        },
        items: [
          {
            xtype: 'component',
            flex: 0,
            cls: 'heading',
            html: 'Vehicles'
          }, {
            xtype: 'component',
            flex: 0,
            cls: 'horizontal-rule'
          }, {
            xtype: 'container',
            ctype: 'vehiclesList',
            width: '100%',
            flex: 0,
            layout: 'vbox'
          }, {
            xtype: 'container',
            flex: 0,
            height: 110,
            width: '100%',
            padding: '0 0 5 0',
            layout: {
              type: 'vbox',
              pack: 'center',
              align: 'center'
            },
            items: [
              {
                xtype: 'button',
                ui: 'action',
                cls: 'button-pop',
                text: 'Add Vehicle',
                flex: 0,
                handler: function() {
                  return this.up().up().up().fireEvent('editVehicle', 'new', false);
                }
              }
            ]
          }
        ]
      }, {
        xtype: 'spacer',
        flex: 1
      }
    ]
  }
});
