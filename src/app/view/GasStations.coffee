Ext.define 'Purple.view.GasStations'
  extend: 'Ext.form.Panel'
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
            flex: 0
            cls: 'heading'
            html: 'Gas Stations'
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'textfield'
            flex: 0
            name: 'address_street'
            label: '76'
            labelWidth: 36
            value: '9988 Wilshire Blvd., Beverly Hills, CA 90210'
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
            xtype: 'textfield'
            flex: 0
            name: 'address_street'
            label: '76'
            labelWidth: 36
            value: '9081 W Pico Blvd., Los Angeles, CA 90035'
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
            xtype: 'textfield'
            flex: 0
            name: 'address_street'
            label: 'Shell'
            labelWidth: 57
            value: '391 S Robertson Blvd., Beverly Hills, CA 90211'
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
            xtype: 'textfield'
            flex: 0
            name: 'address_street'
            label: '76'
            labelWidth: 36
            value: '1460 S La Cienega Blvd., Los Angeles, CA 90035'
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
            xtype: 'textfield'
            flex: 0
            name: 'address_street'
            label: '76'
            labelWidth: 36
            value: '7861 Melrose Ave., Los Angeles, CA 90046'
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
            xtype: 'textfield'
            flex: 0
            name: 'address_street'
            label: 'Shell'
            labelWidth: 57
            value: '7861 Melrose Ave., Los Angeles, CA 90046'
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
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]

