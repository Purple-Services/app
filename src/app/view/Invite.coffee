Ext.define 'Purple.view.Invite'
  extend: 'Ext.Container'
  xtype: 'invite'
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
      'invite-form'
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
            html: 'Get Free Gas!'
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'component'
            flex: 0
            html: """
              Give friends 5 gallons of free gas. After they make their
              first order, you'll get 5 gallons too!
              <div style="text-align: center; padding: 35px 0px 0px 0px; color: #ba1c8d">
                Coupon Code: CHRIS003
              </div>
            """
            cls: 'field-label-text'
          }
          {
            xtype: 'container'
            flex: 0
            height: 110
            width: '100%'
            padding: '10 0 5 0'
            layout:
              type: 'vbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Email Invite'
                flex: 0
                width: 200
                margin: '0 0 20 0'
                handler: ->
                  plugins?.socialsharing?.shareViaEmail(
                    'Here is my message.',
                    'The Subject',
                    null,
                    null,
                    null,
                    null,
                    (->), # success, first arg either true or false
                    (->)  # fatal error
                  )
              }
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop button-pop-dark'
                text: 'Text Invite'
                flex: 0
                width: 200
                handler: ->
                  #@up().up().up().fireEvent 'sendInvites'
                  plugins?.socialsharing?.shareViaSMS(
                    'My message here',
                    null,
                    (->),
                    (->)
                  )
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
