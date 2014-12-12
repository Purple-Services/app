Ext.define 'Purple.view.MapForm'
  extend: 'Ext.form.Panel'
  xtype: 'mapform'
  requires: [
    'Ext.form.*'
    'Ext.field.*'
    'Ext.Button'
  ]
  config:
    layout: 'vbox'
    cls: 'offwhite-bg'
    scrollable: no
    submitOnAction: no
    items: [
      {
        xtype: 'map'
        id: 'gmap'
        flex: 1
        # useCurrentLocation: yes # might want to handle this myself
        useCurrentLocation: no
        mapOptions:
          zoom: 16
          mapTypeControl: no
          zoomControl: no
          streetViewControl: no
      }
      {
        xtype: 'component'
        flex: 0
        height: 10
      }
      {
        xtype: 'textfield'
        flex: 0
        name: 'request_address'
        cls: 'special-input'
        clearIcon: no
      }
      {
        xtype: 'container'
        flex: 0
        height: 110
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
            text: 'Request Gas'
            flex: 0
          }
        ]
      }
      
    ]
