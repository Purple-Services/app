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
              Get <span style="font-weight: 900">#{localStorage['purpleReferralReferrerGallons']} gallons free</span> whenever
              your friends use your coupon code. Plus, they'll get $#{Math.floor(util.centsToDollars(Math.abs(localStorage['purpleReferralReferredValue'])))} off their order!
              <div style="text-align: center; padding: 20px 0px 0px 0px; color: #ba1c8d">
                Share Coupon Code: <span style="font-weight: 900">#{localStorage['purpleUserReferralCode']}</span>
              </div>
            """
            cls: 'loose-text'
          }
          {
            xtype: 'container'
            flex: 0
            height: 110
            width: '100%'
            padding: '7 0 5 0'
            layout:
              type: 'vbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Email'
                flex: 0
                width: 170
                margin: '0 0 15 0'
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
                text: 'Text'
                flex: 0
                width: 170
                margin: '0 0 15 0'
                handler: ->
                  #@up().up().up().fireEvent 'sendInvites'
                  plugins?.socialsharing?.shareViaSMS(
                    'My message here',
                    null,
                    (->),
                    (->)
                  )
              }
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop button-pop-facebook'
                text: 'Facebook'
                flex: 0
                width: 170
                margin: '0 0 15 0'
                handler: ->
                  plugins?.socialsharing?.shareViaFacebook(
                    'Message via Facebook',
                    null, # img
                    "#{util.WEB_SERVICE_BASE_URL}download",
                    (->),
                    (->)
                  )
              }
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop button-pop-twitter'
                text: 'Tweet'
                flex: 0
                width: 170
                handler: ->
                  plugins?.socialsharing?.shareViaTwitter(
                    'Message via Twitter',
                    null, # img
                    "#{util.WEB_SERVICE_BASE_URL}download"
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
