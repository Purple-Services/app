Ext.define('Purple.view.EditAccountForm', {
  extend: 'Ext.form.Panel',
  xtype: 'editaccountform',
  requires: ['Ext.form.*', 'Ext.field.*', 'Ext.Button'],
  config: {
    layout: {
      type: 'hbox',
      pack: 'start',
      align: 'start'
    },
    height: '100%',
    submitOnAction: false,
    cls: ['request-form', 'vehicle-form', 'accent-bg', 'slideable'],
    scrollable: {
      disabled: true
    },
    items: [
      {
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
            ctype: 'editAccountFormHeading',
            cls: 'heading',
            html: 'Edit Account'
          }, {
            xtype: 'component',
            flex: 0,
            cls: 'horizontal-rule'
          }, {
            xtype: 'textfield',
            ctype: 'editAccountName',
            name: 'name',
            label: 'Name',
            labelWidth: 70,
            flex: 0,
            cls: ['bottom-margin'],
            clearIcon: false
          }, {
            xtype: 'textfield',
            ctype: 'editAccountPhoneNumber',
            name: 'phone_number',
            label: 'Phone',
            labelWidth: 70,
            flex: 0,
            cls: ['bottom-margin'],
            clearIcon: false
          }, {
            xtype: 'textfield',
            ctype: 'editAccountEmail',
            name: 'email',
            label: 'Email',
            labelWidth: 70,
            flex: 0,
            cls: ['bottom-margin'],
            clearIcon: false
          }, {
            xtype: 'container',
            flex: 0,
            height: 110,
            width: '100%',
            padding: '0 0 5 0',
            layout: {
              type: 'vbox',
              pack: 'center',
              align: 'center'
            },
            items: [
              {
                xtype: 'button',
                ui: 'action',
                cls: 'button-pop',
                text: 'Save Changes',
                flex: 0,
                handler: function() {
                  return this.up().up().up().fireEvent('saveChanges', this.up().up().up().config.saveChangesCallback);
                }
              }
            ]
          }
        ]
      }, {
        xtype: 'spacer',
        flex: 1
      }
    ]
  }
});
