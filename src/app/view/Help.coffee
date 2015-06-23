Ext.define 'Purple.view.Help'
  extend: 'Ext.Container'
  xtype: 'help'
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
            html: 'Help / FAQ<span style="text-transform: lowercase;">s</span>'
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'textfield'
            flex: 0
            label: 'What is Purple?'
            labelWidth: '100%'
            cls: [
              #'click-to-edit'
              'bottom-margin'
            ]
            disabled: yes
            listeners:
              initialize: (field) ->
                field.element.on 'tap', ->
                  text = Ext.ComponentQuery.query('#q1text')[0]
                  if text.isHidden()
                    text.show()
                  else
                    text.hide()
          }
          {
            xtype: 'component'
            id: 'q1text'
            cls: 'accordion-text'
            showAnimation: 'fadeIn'
            hidden: yes
            html: 'Purple is a gas delivery service. Simply request gas and we will come to your vehicle and fill it up.'
          }
          {
            xtype: 'textfield'
            flex: 0
            label: 'How do I request a fill up?'
            labelWidth: '100%'
            cls: [
              #'click-to-edit'
              'bottom-margin'
            ]
            disabled: yes
            listeners:
              initialize: (field) ->
                field.element.on 'tap', ->
                  text = Ext.ComponentQuery.query('#q2text')[0]
                  if text.isHidden()
                    text.show()
                  else
                    text.hide()
          }
          {
            xtype: 'component'
            id: 'q2text'
            cls: 'accordion-text'
            showAnimation: 'fadeIn'
            hidden: yes
            html: 'Use the "Request Gas" tab to request a gas delivery. Choose your location by moving the pin on the map or by typing you address into the box.'
          }
          {
            xtype: 'textfield'
            flex: 0
            label: 'How do I become a courier?'
            labelWidth: '100%'
            cls: [
              #'click-to-edit'
              'bottom-margin'
            ]
            disabled: yes
            listeners:
              initialize: (field) ->
                field.element.on 'tap', ->
                  text = Ext.ComponentQuery.query('#q3text')[0]
                  if text.isHidden()
                    text.show()
                  else
                    text.hide()
          }
          {
            xtype: 'component'
            id: 'q3text'
            cls: 'accordion-text'
            showAnimation: 'fadeIn'
            hidden: yes
            html: 'If you are interested in becoming a courier for Purple Services and live in the Los Angeles area, please send an email to us at <a href="mailto:info@purpledelivery.com" target="_blank">info@purpledelivery.com</a>.'
          }
          {
            xtype: 'textfield'
            flex: 0
            label: 'How do I check the status of my current order?'
            labelWidth: '100%'
            cls: [
              #'click-to-edit'
              'bottom-margin'
            ]
            disabled: yes
            listeners:
              initialize: (field) ->
                field.element.on 'tap', ->
                  text = Ext.ComponentQuery.query('#q4text')[0]
                  if text.isHidden()
                    text.show()
                  else
                    text.hide()
          }
          {
            xtype: 'component'
            id: 'q4text'
            cls: 'accordion-text'
            showAnimation: 'fadeIn'
            hidden: yes
            html: 'To check on the status of a current or past order, please use the "Orders" tab.'
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]
