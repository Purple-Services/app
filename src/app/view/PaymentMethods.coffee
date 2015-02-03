Ext.define 'Purple.view.PaymentMethods'
  extend: 'Ext.form.Panel'
  xtype: 'paymentmethods'
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
    listeners:
      initialize: ->
        @fireEvent 'loadPaymentMethodsList'
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
            html: 'Payment Methods'
            items: [
              {
                xtype: 'button'
                ui: 'plain'
                text: 'Back'
                cls: [
                  'right-side-aligned-with-heading'
                  'link'
                ] 
                handler: ->
                  @up().up().up().fireEvent 'backToAccount'
              }
            ]
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'container'
            ctype: 'paymentMethodsList'
            flex: 0
            layout: 'vbox'
          }
          {
            xtype: 'container'
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
                text: 'Add Card'
                flex: 0
                handler: ->
                  @up().up().up().fireEvent 'editPaymentMethod', 'new'
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

 
