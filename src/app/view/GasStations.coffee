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
            xtype: 'textfield'
            flex: 0
            name: 'address_street'
            label: 'ARCO'
            labelWidth: 62
            value: '7901 Sunset Blvd., Los Angeles, CA 90046'
            disabled: yes
            cls: [
              'visibly-disabled'
              'bottom-margin'
            ]
            listeners:
              initialize: (field) ->
                field.element.on 'tap', ->
                  window.location.href = "comgooglemaps://?daddr=#{encodeURIComponent(field.getValue()).replace(/%20/g, "+").replace(/%2C/g, ",")}&directionsmode=driving"
          }
          {
            xtype: 'component'
            flex: 0
            html: """
              Tap on a gas station to open in Google Maps.
            """
          }
          {
            xtype: 'container'
            ctype: 'blacklistGasStationButtonContainer'
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
                text: 'Blacklist Gas Station'
                flex: 0
                handler: ->
                  @up().fireEvent 'blacklistGasStation'
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

