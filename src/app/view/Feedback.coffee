Ext.define 'Purple.view.Feedback'
  extend: 'Ext.form.Panel'
  xtype: 'feedback'
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
      translatable:
        translationMethod: 'auto'
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
            html: 'Feedback'
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'component'
            ctype: 'feedbackThankYouMessage'
            showAnimation: 'fadeIn'
            hideAnimation: 'fadeOut'
            flex: 0
            html: '<span style="color: #BA1C8D;">Thank you for your message.</span>'
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
            html: 'We appreciate your feedback and/or suggestions. Thank you for helping us to improve our service.'
            cls: 'loose-text'
          }
          {
            xtype: 'textareafield'
            ctype: 'feedbackTextField'
            name: 'text'
            maxRows: 4
          }
          {
            xtype: 'container'
            id: 'sendFeedbackButtonContainer'
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
                text: 'Send Feedback'
                flex: 0
                handler: ->
                  @up().up().up().fireEvent 'sendFeedback'
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
