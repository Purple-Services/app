Ext.define 'Purple.view.EditPaymentMethodForm',
  extend: 'Ext.form.Panel'
  xtype: 'editpaymentmethodform'
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
      'accent-bg'
      'slideable'
    ]
    # because of a bug with the CVC input field when scrollable, we disable
    # when make this page not scrollable on Android and cros our fingers that
    # the whole page will fit on user's screen
    scrollable:
      disabled: Ext.os.name is "Android"
      direction: 'vertical'
      directionLock: yes
      translatable:
        translationMethod: 'auto'
      
    listeners:
      initialize: ->
        if @config.paymentMethodId isnt 'new'
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
                  text: 'Delete Card'
                  handler: =>
                    @fireEvent 'deletePaymentMethod', @config.paymentMethodId
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
            ctype: 'editPaymentMethodFormHeading'
            cls: 'heading'
            html: ''
          }
          {
            xtype: 'component'
            flex: 0
            cls: [
              'horizontal-rule'
              'purple-rule'
            ]
          }
          # {
          #   xtype: 'textfield'
          #   ctype: 'editPaymentMethodFormCardName'
          #   name: 'card_name'
          #   label: 'Name on Card'
          #   labelWidth: 125
          #   flex: 0
          #   cls: [
          #     'bottom-margin'
          #     'uppercase-input'
          #   ]
          #   clearIcon: no
          # }
          {
            xtype: 'creditcardfield'
            ctype: 'editPaymentMethodFormCardNumber'
            name: 'card_number'
            label: 'Card Number'
            labelWidth: 145
            flex: 0
            cls: [
              'bottom-margin'
              'uppercase-input'
            ]
            clearIcon: no
            component:
              type: 'tel'
          }
          {
            xtype: 'selectfield'
            flex: 0
            name: 'card_exp_month'
            ctype: 'editPaymentMethodFormMonth'
            label: 'Exp. Month'
            labelWidth: 125
            listPicker:
              title: 'Expiration Month'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            options: [
              {
                text: '1 (January)'
                value: '1'
              }
              {
                text: '2 (February)'
                value: '2'
              }
              {
                text: '3 (March)'
                value: '3'
              }
              {
                text: '4 (April)'
                value: '4'
              }
              {
                text: '5 (May)'
                value: '5'
              }
              {
                text: '6 (June)'
                value: '6'
              }
              {
                text: '7 (July)'
                value: '7'
              }
              {
                text: '8 (August)'
                value: '8'
              }
              {
                text: '9 (September)'
                value: '9'
              }
              {
                text: '10 (October)'
                value: '10'
              }
              {
                text: '11 (November)'
                value: '11'
              }
              {
                text: '12 (December)'
                value: '12'
              }
            ]
          }
          {
            xtype: 'selectfield'
            flex: 0
            name: 'card_exp_year'
            ctype: 'editPaymentMethodFormYear'
            label: 'Exp. Year'
            labelWidth: 125
            listPicker:
              title: 'Expiration Year'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            options: [
              {
                text: '2015'
                value: '2015'
              }
              {
                text: '2016'
                value: '2016'
              }
              {
                text: '2017'
                value: '2017'
              }
              {
                text: '2018'
                value: '2018'
              }
              {
                text: '2019'
                value: '2019'
              }
              {
                text: '2020'
                value: '2020'
              }
              {
                text: '2021'
                value: '2021'
              }
              {
                text: '2022'
                value: '2022'
              }
              {
                text: '2023'
                value: '2023'
              }
              {
                text: '2024'
                value: '2024'
              }
              {
                text: '2025'
                value: '2025'
              }
              {
                text: '2026'
                value: '2026'
              }
              {
                text: '2027'
                value: '2027'
              }
              {
                text: '2028'
                value: '2028'
              }
              {
                text: '2029'
                value: '2029'
              }
              {
                text: '2030'
                value: '2030'
              }
              {
                text: '2031'
                value: '2031'
              }
              {
                text: '2032'
                value: '2032'
              }
              {
                text: '2033'
                value: '2033'
              }
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'editPaymentMethodFormCVC'
            name: 'card_cvc'
            label: 'CVC'
            labelWidth: 125
            flex: 0
            cls: [
              'bottom-margin'
              'uppercase-input'
            ]
            clearIcon: no
            component:
              type: 'tel'
          }
          {
            xtype: 'textfield'
            ctype: 'editPaymentMethodFormBillingZip'
            name: 'card_billing_zip'
            label: 'Billing ZIP Code'
            labelWidth: 175
            flex: 0
            cls: [
              'bottom-margin'
              'uppercase-input'
            ]
            clearIcon: no
            component:
              type: 'tel'
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

