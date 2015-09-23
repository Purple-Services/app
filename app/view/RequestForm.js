// Generated by CoffeeScript 1.9.3
Ext.define('Purple.view.RequestForm', {
  extend: 'Ext.form.Panel',
  xtype: 'requestform',
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
      directionLock: true,
      translatable: {
        translationMethod: 'auto'
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
            html: 'Request Gas'
          }, {
            xtype: 'component',
            flex: 0,
            cls: 'horizontal-rule'
          }, {
            xtype: 'selectfield',
            ctype: 'requestFormVehicleSelect',
            flex: 0,
            name: 'vehicle',
            label: 'Vehicle',
            listPicker: {
              title: 'Select a Vehicle'
            },
            cls: ['click-to-edit', 'bottom-margin'],
            options: []
          }, {
            xtype: 'selectfield',
            ctype: 'requestFormGallonsSelect',
            flex: 0,
            name: 'gallons',
            label: 'Gallons',
            listPicker: {
              title: 'Number of Gallons'
            },
            cls: ['click-to-edit', 'bottom-margin', 'visibly-disabled'],
            disabled: true,
            options: []
          }, {
            xtype: 'selectfield',
            ctype: 'requestFormTimeSelect',
            flex: 0,
            name: 'time',
            label: 'Time',
            listPicker: {
              title: 'Select a Time'
            },
            cls: ['click-to-edit', 'bottom-margin', 'visibly-disabled'],
            disabled: true,
            options: []
          }, {
            xtype: 'component',
            flex: 0,
            cls: 'horizontal-rule'
          }, {
            xtype: 'component',
            flex: 0,
            html: 'Special Instructions',
            cls: 'field-label-text'
          }, {
            xtype: 'textareafield',
            name: 'special_instructions',
            maxRows: 3
          }, {
            xtype: 'hiddenfield',
            name: 'lat'
          }, {
            xtype: 'hiddenfield',
            name: 'lng'
          }, {
            xtype: 'hiddenfield',
            name: 'address_street'
          }, {
            xtype: 'hiddenfield',
            name: 'address_zip'
          }, {
            xtype: 'container',
            id: 'sendRequestButtonContainer',
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
                ctype: 'sendRequestButton',
                ui: 'action',
                cls: 'button-pop',
                text: 'Review Order',
                disabled: true,
                flex: 0,
                handler: function() {
                  return this.up().up().up().fireEvent('sendRequest');
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
