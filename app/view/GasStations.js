Ext.define('Purple.view.GasStations', {
  extend: 'Ext.Container',
  xtype: 'gasstations',
  requires: ['Ext.form.*', 'Ext.field.*', 'Ext.Button'],
  config: {
    layout: {
      type: 'hbox',
      pack: 'start',
      align: 'start'
    },
    height: '100%',
    submitOnAction: false,
    cls: ['request-form', 'vehicle-form', 'view-order', 'accent-bg', 'slideable'],
    scrollable: {
      direction: 'vertical',
      directionLock: true
    },
    items: [
      {
        xtype: 'spacer',
        flex: 1
      }, {
        xtype: 'container',
        flex: 0,
        width: '85%',
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
            html: 'Gas Stations'
          }, {
            xtype: 'component',
            flex: 0,
            cls: 'horizontal-rule'
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: 'ARCO',
            labelWidth: 62,
            value: '7901 Sunset Blvd., Los Angeles, CA 90046',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: 'ARCO',
            labelWidth: 62,
            value: '6100 Franklin Ave., Los Angeles, CA 90028',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: 'ARCO',
            labelWidth: 62,
            value: '655 N Western Ave., Los Angeles, CA 90004',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: 'ARCO',
            labelWidth: 62,
            value: '1255 Highland Ave., Los Angeles, CA 90038',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: 'ARCO',
            labelWidth: 62,
            value: '8770 W Olympic Blvd., Los Angeles, CA 90035',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: 'ARCO',
            labelWidth: 62,
            value: '9779 W Pico Blvd., Los Angeles, CA 90035',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: 'ARCO',
            labelWidth: 62,
            value: '3479 Motor Ave., Los Angeles, CA 90034',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: 'ARCO',
            labelWidth: 62,
            value: '12332 W Washington Blvd., Los Angeles, CA 90066',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: 'ARCO',
            labelWidth: 62,
            value: '332 Pico Blvd., Santa Monica, CA 90405',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: '76',
            labelWidth: 36,
            value: '9988 Wilshire Blvd., Beverly Hills, CA 90210',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: '76',
            labelWidth: 36,
            value: '9081 W Pico Blvd., Los Angeles, CA 90035',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: 'Shell',
            labelWidth: 57,
            value: '391 S Robertson Blvd., Beverly Hills, CA 90211',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: '76',
            labelWidth: 36,
            value: '1460 S La Cienega Blvd., Los Angeles, CA 90035',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: '76',
            labelWidth: 36,
            value: '7861 Melrose Ave., Los Angeles, CA 90046',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'textfield',
            flex: 0,
            name: 'address_street',
            label: 'Shell',
            labelWidth: 57,
            value: '7861 Melrose Ave., Los Angeles, CA 90046',
            disabled: true,
            cls: ['visibly-disabled', 'bottom-margin'],
            listeners: {
              initialize: function(field) {
                return field.element.on('tap', function() {
                  return window.location.href = "comgooglemaps://?daddr=" + (encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")) + "&directionsmode=driving";
                });
              }
            }
          }, {
            xtype: 'component',
            flex: 0,
            html: "Tap on a gas station to open in Google Maps."
          }
        ]
      }, {
        xtype: 'spacer',
        flex: 1
      }
    ]
  }
});
