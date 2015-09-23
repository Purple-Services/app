Ext.define 'Purple.view.Order',
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
      translatable:
        translationMethod: 'auto'
    listeners:
      initialize: ->
        if util.CANCELLABLE_STATUSES.indexOf(@config.status) isnt -1 and
        not util.ctl('Account').isCourier()
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
            xtype: 'component'
            flex: 0
            ctype: 'editOrderFormHeading'
            cls: 'heading'
            html: 'View Order'
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'hiddenfield'
            name: 'status'
          }
          {
            xtype: 'textfield'
            flex: 0
            name: 'display_status'
            label: 'Status'
            disabled: yes
            cls: [
              'big-and-bold'
            ]
          }
          {
            xtype: 'container'
            ctype: 'nextStatusButtonContainer'
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
                text: 'Begin Servicing'
                flex: 0
                handler: ->
                  @up().up().up().fireEvent 'nextStatus'
              }
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
            ctype: 'orderTimePlaced'
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
            ctype: 'orderTimeDeadline'
            flex: 0
            name: 'time_deadline'
            label: 'Deadline'
            labelWidth: 95
            disabled: yes
            hidden: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'orderDisplayTime'
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
            ctype: 'orderVehicle'
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
            ctype: 'orderGasPrice'
            flex: 0
            name: 'gas_price_display'
            label: 'Gas Price'
            labelWidth: 115
            disabled: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'orderGallons'
            flex: 0
            name: 'gallons'
            label: 'Gallons'
            disabled: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'orderGasType'
            flex: 0
            name: 'gas_type'
            label: 'Gas Type'
            labelWidth: 95
            disabled: yes
            hidden: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'moneyfield'
            ctype: 'orderServiceFee'
            flex: 0
            name: 'service_fee_display'
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
            ctype: 'orderTotalPrice'
            flex: 0
            name: 'total_price_display'
            label: 'Total'
            disabled: yes
            style: 'margin-bottom: 25px;'
            cls: [
              'highlighted'
            ]
          }
          {
            xtype: 'component'
            ctype: 'orderHorizontalRuleAboveVehicle'
            flex: 0
            cls: 'horizontal-rule'
            hidden: yes
          }
          {
            xtype: 'textfield'
            ctype: 'orderVehicleMake'
            flex: 0
            name: 'vehicle_make'
            label: 'Vehicle Make'
            labelWidth: 124
            disabled: yes
            hidden: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'orderVehicleModel'
            flex: 0
            name: 'vehicle_model'
            label: 'Model'
            labelWidth: 75
            disabled: yes
            hidden: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'orderVehicleYear'
            flex: 0
            name: 'vehicle_year'
            label: 'Year'
            labelWidth: 75
            disabled: yes
            hidden: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'orderVehicleColor'
            flex: 0
            name: 'vehicle_color'
            label: 'Color'
            labelWidth: 75
            disabled: yes
            hidden: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'orderVehicleLicensePlate'
            flex: 0
            name: 'vehicle_license_plate'
            label: 'License Plate'
            labelWidth: 124
            disabled: yes
            hidden: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'component'
            ctype: 'orderVehiclePhoto'
            flex: 0
            hidden: yes
          }
          {
            xtype: 'component'
            ctype: 'orderHorizontalRuleAboveCustomerInfo'
            flex: 0
            cls: 'horizontal-rule'
            hidden: yes
          }
          {
            xtype: 'textfield'
            ctype: 'orderCustomerName'
            flex: 0
            name: 'customer_name'
            label: 'Name'
            labelWidth: 75
            disabled: yes
            hidden: yes
            cls: [
              'visibly-disabled'
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'orderCustomerPhone'
            margin: '0 0 30 0'
            flex: 0
            name: 'customer_phone'
            label: 'Phone'
            labelWidth: 75
            disabled: yes
            hidden: yes
            cls: [
              'visibly-disabled'
            ]
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]
