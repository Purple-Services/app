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
            html: 'Subscriptions'
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
            xtype: 'component'
            flex: 0
            html: 'Select one of the plans to get more information. You can cancel at any time.'
            cls: 'loose-text'
          }
          {
            xtype: 'textfield'
            flex: 0
            label: 'Regular Membership: $7.99'
            labelWidth: '100%'
            cls: [
              'bottom-margin'
              'faq-question'
              'click-to-edit'
              'point-down'
            ]
            disabled: yes
            listeners:
              initialize: (field) ->
                field.element.on 'tap', ->
                  text = Ext.ComponentQuery.query("#level-1-details")[0]
                  if text.isHidden()
                    text.show()
                    field.addCls 'point-up'
                  else
                    text.hide()
                    field.removeCls 'point-up'
          }
          {
            xtype: 'container'
            flex: 0
            id: 'level-1-details'
            cls: [
              'accordion-text'
              'smaller-button-pop'
            ]
            showAnimation: 'fadeIn'
            hidden: yes
            items: [
              {
                xtype: 'component'
                margin: '5 0 10 0'
                style: "text-align: center;"
                html: """
                  3 x 3 hour orders
                """
              }
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Subscribe to Regular'
                flex: 0
                margin: '0 0 15 0'
                handler: ->
                  @up().up().up().fireEvent 'subscribe', 1
              }
            ]
          }
          {
            xtype: 'textfield'
            flex: 0
            label: 'Premium Membership: $15.99'
            labelWidth: '100%'
            cls: [
              'bottom-margin'
              'faq-question'
              'click-to-edit'
              'point-down'
            ]
            disabled: yes
            listeners:
              initialize: (field) ->
                field.element.on 'tap', ->
                  text = Ext.ComponentQuery.query("#level-2-details")[0]
                  if text.isHidden()
                    text.show()
                    field.addCls 'point-up'
                  else
                    text.hide()
                    field.removeCls 'point-up'
          }
          {
            xtype: 'container'
            flex: 0
            id: 'level-2-details'
            cls: [
              'accordion-text'
              'smaller-button-pop'
            ]
            showAnimation: 'fadeIn'
            hidden: yes
            items: [
              {
                xtype: 'component'
                margin: '5 0 10 0'
                style: "text-align: center;"
                html: """
                  4 x 1 hour orders
                  <br />1 free tire pressure check
                """
              }
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Subscribe to Premium'
                flex: 0
                margin: '0 0 15 0'
                handler: ->
                  @up().up().up().fireEvent 'subscribe', 2
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
