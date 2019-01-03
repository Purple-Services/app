Ext.define 'Purple.view.GasPurchases',
  extend: 'Ext.form.Panel'
  xtype: 'gaspurchases'
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
            ctype: 'addGasPurchaseFormHeading'
            cls: 'heading'
            html: 'Gas Purchases'
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
            ctype: 'gasGasTypeSelectField'
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
            xtype: 'textfield'
            ctype: 'gasGallonsField'
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
            xtype: 'textfield'
            ctype: 'gasTotalPriceField'
            name: 'total_price'
            label: 'Total Price'
            labelWidth: 125
            flex: 0
            cls: [
              'bottom-margin'
            ]
            clearIcon: no
            component:
              type: 'number'
          }
          
          {
            xtype: 'container'
            ctype: 'addGasPurchaseButtonContainer'
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
                text: 'Add'
                flex: 0
                handler: ->
                  @up().fireEvent 'addGasPurchase'
              }
            ]
          }
          {
            xtype: 'container'
            ctype: 'cancelEditGasPurchaseButtonContainer'
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
                  @up().fireEvent 'cancelEditGasPurchase'
              }
            ]
          }
          {
            xtype: 'container'
            ctype: 'gasPurchasesList'
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
