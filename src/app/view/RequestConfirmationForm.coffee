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
            html: 'Confirmation'
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
            xtype: 'textfield'
            flex: 0
            name: 'time'
            label: 'Time'
            disabled: yes
          }
          {
            xtype: 'textfield'
            flex: 0
            name: 'vehicle'
            label: 'Vehicle'
            disabled: yes
          }
          {
            xtype: 'textfield'
            flex: 0
            name: 'address_street'
            label: 'Location'
            labelWidth: 89
            disabled: yes
            cls: 'bottom-margin'
          }
          {
            xtype: 'component'
            id: 'specialInstructionsConfirmationLabel'
            flex: 0
            html: 'Special Instructions'
            cls: 'field-label-text'
          }
          {
            xtype: 'textareafield'
            id: 'specialInstructionsConfirmation'
            name: 'special_instructions'
            maxRows: 4
            disabled: yes
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
              'bottom-margin'
            ]
          }
          {
            xtype: 'textfield'
            flex: 0
            name: 'gallons'
            label: 'Gallons'
            disabled: yes
            cls: [
              'bottom-margin'
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
              'bottom-margin'
            ]
          }
          {
            xtype: 'moneyfield'
            flex: 0
            name: 'total_price'
            label: 'Total'
            disabled: yes
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
