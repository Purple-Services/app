Ext.define 'Purple.view.RequestConfirmationForm'
  extend: 'Ext.form.Panel'
  xtype: 'requestconfirmationform'
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
    submitOnAction: no
    cls: [
      'request-form'
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
            xtype: 'container'
            flex: 0
            cls: 'heading'
            html: 'Review'
            items: [
              {
                xtype: 'button'
                ui: 'plain'
                text: 'Edit Order'
                cls: [
                  'right-side-aligned-with-heading'
                  'link'
                ] 
                handler: ->
                  @up().up().up().fireEvent 'backToRequestForm'
              }
            ]
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'hiddenfield'
            name: 'time'
          }
          {
            xtype: 'textfield'
            flex: 0
            name: 'display_time'
            label: 'Time'
            disabled: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'hiddenfield'
            name: 'vehicle_id'
          }
          {
            xtype: 'textfield'
            flex: 0
            name: 'vehicle'
            label: 'Vehicle'
            disabled: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'textfield'
            id: 'addressStreetConfirmation'
            flex: 0
            name: 'address_street'
            label: 'Location'
            labelWidth: 89
            disabled: yes
            cls: [
              'visibly-disabled'
              'bottom-margin'
            ]
          }
          {
            xtype: 'component'
            id: 'specialInstructionsConfirmationLabel'
            flex: 0
            html: 'Special Instructions'
            cls: [
              'visibly-disabled'
              'field-label-text'
            ]
          }
          {
            xtype: 'textareafield'
            id: 'specialInstructionsConfirmation'
            name: 'special_instructions'
            maxRows: 4
            disabled: yes
            cls: [
              'visibly-disabled'
              'field-label-text'
            ]
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'moneyfield'
            flex: 0
            name: 'gas_price'
            label: 'Gas Price'
            labelWidth: 115
            disabled: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'textfield'
            flex: 0
            name: 'gallons'
            label: 'Gallons'
            disabled: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'moneyfield'
            flex: 0
            name: 'service_fee'
            label: 'Service Fee'
            labelWidth: 115
            disabled: yes
            cls: [
              'visibly-disabled'
              'bottom-margin'
            ]
          }
          {
            xtype: 'moneyfield'
            flex: 0
            name: 'total_price'
            label: 'Total'
            disabled: yes
            cls: [
              'highlighted'
            ]
          }
          # hidden fields for flowing data
          {
            xtype: 'hiddenfield'
            name: 'lat'
          }
          {
            xtype: 'hiddenfield'
            name: 'lng'
          }
          {
            xtype: 'hiddenfield'
            name: 'address_zip'
          }
          {
            xtype: 'container'
            id: 'cofirmOrderButtonContainer'
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
                text: 'Confirm Order'
                flex: 0
                handler: ->
                  @up().up().up().fireEvent 'confirmOrder'
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

