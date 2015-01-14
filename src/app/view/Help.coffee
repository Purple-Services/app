Ext.define 'Purple.view.Help'
  extend: 'Ext.form.Panel'
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
            html: 'Lorem ipsum dolor sit amet, consectetur adipsing elit. Vestibu lum hend rerit dolor a massa suscipt, sed accums an velit laoreet. Sociie natoqwu dagsafa.'
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
            html: 'Lorem ipsum dolor sit amet, consectetur adipsing elit. Vestibu lum hend rerit dolor a massa suscipt, sed accums an velit laoreet. Sociie natoqwu dagsafa.'
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
            html: 'Lorem ipsum dolor sit amet, consectetur adipsing elit. Vestibu lum hend rerit dolor a massa suscipt, sed accums an velit laoreet. Sociie natoqwu dagsafa. Lorem ipsum dolor sit amet, consectetur adipsing elit. Vestibu lum hend rerit dolor a massa suscipt, sed accums an velit laoreet. Sociie natoqwu dagsafa. Lorem ipsum dolor sit amet, consectetur adipsing elit. Vestibu lum hend rerit dolor a massa suscipt, sed accums an velit laoreet. Sociie natoqwu dagsafa.'
          }
          {
            xtype: 'textfield'
            flex: 0
            label: 'How do I check up on my current or past orders?'
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
            html: 'Lorem ipsum dolor sit amet, consectetur adipsing elit. Vestibu lum hend rerit dolor a massa suscipt, sed accums an velit laoreet. Sociie natoqwu dagsafa.'
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]
