Ext.define 'Purple.view.AccountForm',
  extend: 'Ext.form.Panel'
  xtype: 'accountform'
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
    scrollable:
      direction: 'vertical'
      directionLock: yes
      translatable:
        translationMethod: 'auto'
    cls: [
      'account-form'
      'accent-bg'
      'slideable'
    ]
    listeners:
      initialize: ->
        util.ctl('Account').populateAccountForm()
    items: [
      {
        xtype: 'container'
        id: 'logoutButtonContainer'
        flex: 0
        layout:
          type: 'vbox'
          pack: 'start'
          align: 'center'
        cls: 'links-container'
        style: """
          position: absolute;
          bottom: 15px;
          width: 100%;
          text-align: center;
        """
        items: [
          {
            xtype: 'button'
            ui: 'plain'
            text: 'Logout'
            handler: ->
              @up().up().fireEvent 'logoutButtonTap'
          }
        ]
      }
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
            cls: 'heading'
            html: 'Account'
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'textfield'
            id: 'accountNameField'
            name: 'name'
            label: 'Name'
            flex: 0
            cls: [
              #'click-to-edit'
              'bottom-margin'
            ]
            disabled: yes
          }
          {
            xtype: 'textfield'
            id: 'accountPhoneNumberField'
            flex: 0
            name: 'phone_number'
            label: 'Phone'
            cls: [
              #'click-to-edit'
              'bottom-margin'
            ]
            disabled: yes
          }
          {
            xtype: 'textfield'
            id: 'accountEmailField'
            flex: 0
            name: 'email'
            label: 'Email'
            disabled: yes
          }
          {
            xtype: 'component'
            ctype: 'accountHorizontalRuleAbovePaymentMethod'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'textfield'
            id: 'accountPaymentMethodField'
            flex: 0
            name: 'payment_method'
            label: 'Payment'
            labelWidth: '40%'
            cls: [
              'click-to-edit'
            ]
            disabled: yes
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]
