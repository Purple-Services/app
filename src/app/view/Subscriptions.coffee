Ext.define 'Purple.view.Subscriptions',
  extend: 'Ext.Container'
  xtype: 'subscriptions'
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
      'accent-bg'
      'slideable'
    ]
    scrollable:
      direction: 'vertical'
      directionLock: yes
    listeners:
      initialize: ->
        @fireEvent 'loadSubscriptions', yes, null
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
            html: 'Monthly Membership'
          }
          {
            xtype: 'component'
            flex: 0
            cls: [
              'horizontal-rule'
              'purple-rule'
            ]
          }
          {
            xtype: 'container'
            id: 'subscriptionChoicesContainer'
            flex: 0
            layout:
              type: 'vbox'
              pack: 'start'
              align: 'start'
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]
