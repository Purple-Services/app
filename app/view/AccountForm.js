Ext.define('Purple.view.AccountForm', {
  extend: 'Ext.form.Panel',
  xtype: 'accountform',
  requires: ['Ext.form.*', 'Ext.field.*', 'Ext.Button'],
  config: {
    layout: {
      type: 'hbox',
      pack: 'start',
      align: 'start'
    },
    height: '100%',
    submitOnAction: false,
    scrollable: {
      disabled: true
    },
    cls: ['account-form', 'accent-bg', 'slideable'],
    listeners: {
      initialize: function() {
        return util.ctl('Account').populateAccountForm();
      }
    },
    items: [
      {
        xtype: 'container',
        id: 'logoutButtonContainer',
        flex: 0,
        layout: {
          type: 'vbox',
          pack: 'start',
          align: 'center'
        },
        cls: 'links-container',
        style: "position: absolute;\nbottom: 15px;\nwidth: 100%;\ntext-align: center;",
        items: [
          {
            xtype: 'button',
            ui: 'plain',
            text: 'Logout',
            handler: function() {
              return this.up().up().fireEvent('logoutButtonTap');
            }
          }
        ]
      }, {
        xtype: 'spacer',
        flex: 1
      }, {
        xtype: 'container',
        flex: 0,
        width: '85%',
        layout: {
          type: 'vbox',
          pack: 'start',
          align: 'start'
        },
        items: [
          {
            xtype: 'component',
            flex: 0,
            cls: 'heading',
            html: 'Account'
          }, {
            xtype: 'component',
            flex: 0,
            cls: 'horizontal-rule'
          }, {
            xtype: 'textfield',
            id: 'accountNameField',
            name: 'name',
            label: 'Name',
            labelWidth: 70,
            flex: 0,
            cls: ['click-to-edit', 'bottom-margin'],
            disabled: true
          }, {
            xtype: 'textfield',
            id: 'accountPhoneNumberField',
            flex: 0,
            name: 'phone_number',
            label: 'Phone',
            labelWidth: 70,
            cls: ['click-to-edit', 'bottom-margin'],
            disabled: true
          }, {
            xtype: 'textfield',
            id: 'accountEmailField',
            flex: 0,
            name: 'email',
            label: 'Email',
            labelWidth: 70,
            cls: ['click-to-edit'],
            disabled: true
          }, {
            xtype: 'component',
            ctype: 'accountHorizontalRuleAbovePaymentMethod',
            flex: 0,
            cls: 'horizontal-rule'
          }, {
            xtype: 'textfield',
            id: 'accountPaymentMethodField',
            flex: 0,
            name: 'payment_method',
            label: 'Payment',
            labelWidth: 105,
            cls: ['click-to-edit'],
            disabled: true
          }
        ]
      }, {
        xtype: 'spacer',
        flex: 1
      }
    ]
  }
});
