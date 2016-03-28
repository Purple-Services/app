Ext.define 'Purple.view.GasStations',
  extend: 'Ext.Container'
  xtype: 'gasstations'
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
      'vehicle-form'
      'view-order'
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
            xtype: 'container'
            ctype: 'findGasButtonContainer'
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
                text: 'Find Gas Station'
                flex: 0
                handler: ->
                  @up().fireEvent 'getGasStation'
              }
            ]
          }
          {
            xtype: 'container'
            ctype: 'recommendedGasStation'
            width: '100%'
            flex: 0
            layout: 'vbox'
          }
          {
            xtype: 'container'
            ctype: 'blacklistGasStationButtonContainer'
            layout:
              type: 'vbox'
              pack: 'start'
              align: 'start'
            cls: 'blacklist-button'
            hidden: yes
            items: [
              xtype: 'button'
              ui: 'plain'
              text: 'Report a problem with this gas station?'
              handler: -> 
                @up().fireEvent 'blacklistGasStation'
            ]
          }
          {
            xtype: 'component'
            ctype: 'gasStationTip'
            flex: 0
            padding: '100 0 0 0'
            hidden: yes
            html: """
              Tap on a gas station to open in Google Maps.
            """
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]

