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
            xtype: 'component'
            flex: 0
            cls: 'heading'
            html: 'Gas Stations'
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

