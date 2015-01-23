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
      'accent-bg'
      'slideable'
    ]
    scrollable:
      direction: 'vertical'
      directionLock: yes
    listeners:
      initialize: ->
        if @config.orderId isnt 'new'
          @getAt(1).add [
            {
              xtype: 'spacer'
              flex: 0
              height: 100
              listeners:
                initialize: ->
                  console.log 'heyhey'
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
                  text: 'Delete Order'
                  handler: =>
                    @fireEvent 'deleteOrder', @config.orderId
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
            html: ''
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
            xtype: 'selectfield'
            ctype: 'editOrderFormYear'
            flex: 0
            name: 'year'
            label: 'Year'
            listPicker:
              title: 'Select Order Year'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
            ]
            disabled: yes
            options: [
              'Loading...'
            ]
          }
          {
            xtype: 'selectfield'
            ctype: 'editOrderFormMake'
            flex: 0
            name: 'make'
            label: 'Make'
            listPicker:
              title: 'Select Order Make'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
            ]
            disabled: yes
            options: [
              'Please select year...'
            ]
          }
          {
            xtype: 'selectfield'
            ctype: 'editOrderFormModel'
            flex: 0
            name: 'model'
            label: 'Model'
            listPicker:
              title: 'Select Order Model'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
            ]
            disabled: yes
            options: [
              'Please select make...'
            ]
          }
          {
            xtype: 'selectfield'
            ctype: 'editOrderFormColor'
            flex: 0
            name: 'color'
            label: 'Color'
            listPicker:
              title: 'Select Order Color'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
            ]
            disabled: yes
            options: [
              'Loading...'
            ]
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'selectfield'
            ctype: 'editOrderFormGasType'
            flex: 0
            name: 'gas_type'
            label: 'Gas'
            listPicker:
              title: 'Select Order Gas'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            options: [
              {
                text: 'Unleaded 89 Octane'
                value: '89'
              }
              {
                text: 'Unleaded 91 Octane'
                value: '91'
              }
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'editOrderFormLicensePlate'
            name: 'license_plate'
            label: 'License Plate'
            labelWidth: 125
            flex: 0
            cls: [
              'bottom-margin'
              'uppercase-input'
            ]
            clearIcon: no
          }
          # {
          #   xtype: 'button'
          #   ui: 'plain'
          #   text: 'take photo'
          # }
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
                text: 'Save Changes'
                flex: 0
                handler: ->
                  @up().up().up().fireEvent 'saveChanges', @up().up().up().config.saveChangesCallback
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

