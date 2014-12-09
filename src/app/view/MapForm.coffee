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
        height: 350
        useCurrentLocation: yes
        mapOptions:
          zoom: 16
          mapTypeControl: no
          zoomControl: no
          streetViewControl: no
      }
      {
        xtype: 'component'
        height: 10
      }
      {
        xtype: 'textfield'
        name: 'request_address'
        cls: 'special-input'
        clearIcon: no
      }
      {
        xtype: 'container'
        flex: 1
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
