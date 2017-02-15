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
            html: 'Fleet Deliveries'
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
            label: ' '
            labelWidth: 0
            listPicker:
              title: 'Choose Fleet Location'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
              'no-label'
            ]
            disabled: yes
            options: [
            ]
            listeners:
              change: (field, newValue, oldValue) ->
                @fireEvent 'fleetAccountSelectFieldChange'
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
                text: 'Scan VIN Barcode'
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
            label: 'Plate/Stock'
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
            options: [ # if changing options, also update dashboard-cljs:fleet.cljs:179
              {
                text: '87'
                value: '87'
              }
              {
                text: '89'
                value: '89'
              }
              {
                text: '91'
                value: '91'
              }
              {
                text: 'Regular Diesel'
                value: 'Regular Diesel'
              }
              {
                text: 'Dyed Diesel'
                value: 'Dyed Diesel'
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
                text: 'Add Delivery'
                flex: 0
                handler: ->
                  @up().fireEvent 'addFleetOrder'
              }
            ]
          }
          {
            xtype: 'container'
            ctype: 'cancelEditFleetOrderButtonContainer'
            flex: 0
            height: 70
            width: '100%'
            padding: '0 0 5 0'
            hidden: true
            layout:
              type: 'vbox'
              pack: 'center'
              align: 'center'
            cls: 'smaller-button-pop'
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Cancel'
                flex: 0
                handler: ->
                  @up().fireEvent 'cancelEditFleetOrder'
              }
            ]
          }
          {
            xtype: 'container'
            ctype: 'deliveriesList'
            cls: 'deliveries-list'
            width: '100%'
            flex: 0
            layout: 'vbox'
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]
