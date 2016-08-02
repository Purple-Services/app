Ext.define 'Purple.view.Fleet',
  extend: 'Ext.form.Panel'
  xtype: 'fleet'
  requires: [
    'Ext.form.*'
    'Ext.field.*'
    'Ext.Button'
  ]
  config:
    layout:
      type: 'hbox'
      pack: 'start'
      align: 'start'
    height: '100%'
    submitOnAction: no
    cls: [
      'request-form'
      'vehicle-form'
      'view-order'
      'accent-bg'
      'slideable'
    ]
    scrollable:
      direction: 'vertical'
      directionLock: yes

    items: [
      {
        xtype: 'spacer'
        flex: 1
      }
      {
        xtype: 'container'
        flex: 0
        width: '85%'
        layout:
          type: 'vbox'
          pack: 'start'
          align: 'start'
        items: [
          {
            xtype: 'component'
            flex: 0
            ctype: 'addFleetOrderFormHeading'
            cls: 'heading'
            html: 'Add Fleet Delivery'
          }
          {
            xtype: 'component'
            flex: 0
            cls: [
              'horizontal-rule'
              'purple-rule'
            ]
          }
          {
            xtype: 'selectfield'
            ctype: 'fleetAccountSelectField'
            flex: 0
            name: 'account_id'
            label: 'Account'
            labelWidth: 100
            listPicker:
              title: 'Select a Fleet Account'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
            ]
            disabled: yes
            options: [
            ]
          }
          {
            xtype: 'container'
            ctype: 'scanVinBarcodeButtonContainer'
            flex: 0
            height: 110
            width: '100%'
            padding: '0 0 5 0'
            layout:
              type: 'vbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Scan Barcode'
                flex: 0
                handler: ->
                  @up().fireEvent 'scanBarcode'
              }
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'fleetVinField'
            name: 'vin'
            label: 'VIN'
            labelWidth: 50
            flex: 0
            cls: [
              'bottom-margin'
              'uppercase-input'
            ]
            clearIcon: no
          }
          {
            xtype: 'textfield'
            ctype: 'fleetLicensePlateField'
            name: 'license_plate'
            label: 'License Plate'
            labelWidth: 140
            placeHolder: '(if no vin)'
            flex: 0
            cls: [
              'bottom-margin'
              'uppercase-input'
            ]
            clearIcon: no
          }
          {
            xtype: 'textfield'
            ctype: 'fleetGallonsField'
            name: 'gallons'
            label: 'Gallons'
            labelWidth: 110
            flex: 0
            cls: [
              'bottom-margin'
            ]
            clearIcon: no
            component:
              type: 'number'
          }
          {
            xtype: 'selectfield'
            ctype: 'fleetGasTypeSelectField'
            flex: 0
            name: 'gas_type'
            label: 'Octane'
            labelWidth: 100
            listPicker:
              title: 'Select an Octane'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            options: [
              {
                text: '87'
                value: '87'
              }
              {
                text: '91'
                value: '91'
              }
            ]
          }
          {
            xtype: 'checkboxfield'
            ctype: 'fleetIsTopTierField'
            flex: 0
            name: 'is_top_tier'
            label: 'Top-tier?'
            labelWidth: 170
            cls: [
              'bottom-margin'
            ]
            checked: true
          }
          {
            xtype: 'container'
            ctype: 'addFleetOrderButtonContainer'
            flex: 0
            height: 110
            width: '100%'
            padding: '0 0 5 0'
            layout:
              type: 'vbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Submit Delivery'
                flex: 0
                handler: ->
                  @up().fireEvent 'addFleetOrder'
              }
            ]
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]
