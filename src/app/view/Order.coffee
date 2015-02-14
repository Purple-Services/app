Ext.define 'Purple.view.Order'
  extend: 'Ext.form.Panel'
  xtype: 'order'
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
      'vehicle-form'
      'view-order'
      'accent-bg'
      'slideable'
    ]
    scrollable:
      direction: 'vertical'
      directionLock: yes
    listeners:
      initialize: ->
        if -1 isnt util.CANCELLABLE_STATUSES.indexOf @config.status
          @getAt(1).add [
            {
              xtype: 'spacer'
              flex: 0
              height: 100
            }
            {
              xtype: 'container'
              flex: 0
              layout:
                type: 'vbox'
                pack: 'start'
                align: 'center'
              cls: 'links-container'
              style: """
                width: 100%;
                text-align: center;
                padding-bottom: 20px;
              """
              items: [
                {
                  xtype: 'button'
                  ui: 'plain'
                  text: 'Cancel Order'
                  handler: =>
                    @fireEvent 'cancelOrder', @config.orderId
                }
              ]
            }
          ]
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
            ctype: 'editOrderFormHeading'
            cls: 'heading'
            html: 'View Order'
            items: [
              {
                xtype: 'button'
                ctype: 'backToOrdersButton'
                ui: 'plain'
                text: 'Back to Orders'
                cls: [
                  'right-side-aligned-with-heading'
                  'link'
                ] 
                handler: ->
                  @up().up().up().fireEvent 'backToOrders'
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
            name: 'status'
            label: 'Status'
            disabled: yes
            cls: [
              'big-and-bold'
            ]
          }
          {
            xtype: 'ratingfield'
            ctype: 'orderRating'
            flex: 0
            name: 'number_rating'
            hidden: yes
            label: 'Rating'
            labelWidth: 75
            cls: [
              'big-and-bold'
              'no-background'
            ]
          }
          {
            xtype: 'textareafield'
            ctype: 'textRating'
            name: 'text_rating'
            maxRows: 4
            hidden: yes
            placeHolder: 'Optional comments...'
          }
          {
            xtype: 'container'
            ctype: 'sendRatingButtonContainer'
            flex: 0
            height: 110
            width: '100%'
            padding: '0 0 5 0'
            layout:
              type: 'vbox'
              pack: 'center'
              align: 'center'
            hidden: yes
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Send Rating'
                flex: 0
                handler: ->
                  @up().up().up().fireEvent 'sendRating'
              }
            ]
          }
          {
            xtype: 'component'
            flex: 0
            cls: [
              'horizontal-rule'
              'no-top-margin'
            ]
          }
          {
            xtype: 'textfield'
            flex: 0
            name: 'time_order_placed'
            label: 'Placed'
            disabled: yes
            cls: [
              'visibly-disabled'
            ]
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
            ctype: 'orderAddressStreet'
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
            ctype: 'orderSpecialInstructionsLabel'
            flex: 0
            html: 'Special Instructions'
            cls: [
              'visibly-disabled'
              'field-label-text'
            ]
          }
          {
            xtype: 'textareafield'
            ctype: 'orderSpecialInstructions'
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
            style: 'margin-bottom: 25px;'
            cls: [
              'highlighted'
            ]
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]

