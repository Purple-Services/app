Ext.define 'Purple.view.Orders'
  extend: 'Ext.form.Panel'
  xtype: 'orders'
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
      'accent-bg'
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
            cls: 'heading'
            html: 'Orders'
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]
