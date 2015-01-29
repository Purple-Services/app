Ext.define 'Purple.view.Invite'
  extend: 'Ext.form.Panel'
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
            html: 'Invite a Friend'
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'component'
            ctype: 'inviteThankYouMessage'
            showAnimation: 'fadeIn'
            hideAnimation: 'fadeOut'
            flex: 0
            html: '<span style="color: #BA1C8D;">Invitation sent. Thank you!</span>'
            cls: 'field-label-text'
            hidden: yes
            style: """
              padding-top: 20px;
              padding-bottom: 30px; 
            """
          }
          {
            xtype: 'component'
            flex: 0
            html: 'Your friend\'s email address:'
            cls: 'field-label-text'
          }
          {
            xtype: 'emailfield'
            ctype: 'inviteTextField'
            name: 'text'
          }
          {
            xtype: 'container'
            id: 'sendInvitesButtonContainer'
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
                text: 'Send Invite'
                flex: 0
                handler: ->
                  @up().up().up().fireEvent 'sendInvites'
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
