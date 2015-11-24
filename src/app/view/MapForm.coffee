Ext.define 'Purple.view.MapForm',
  extend: 'Ext.Container'
  xtype: 'mapform'
  requires: [
    'Ext.form.*'
    'Ext.field.*'
    'Ext.Button'
  ]
  config:
    layout: 'vbox'
    height: '100%'
    cls: 'offwhite-bg'
    scrollable: no
    submitOnAction: no
    listeners:
      painted: ->
        mapDom = Ext.get 'gmap'
        styleRule = """
          <style>
            #gmap:after {
              top: #{mapDom.getHeight() / 2}px;
            }
          </style>
        """
        Ext.DomHelper.append mapDom, styleRule
      
    items: [
      # {
      #   xtype: 'component'
      #   id: 'gasPriceMapDisplay'
      #   flex: 0
      #   height: 25
      #   html: """
      #     <div class="gas-price-map-field-section">
      #       12
      #     </div>
      #     <div class="gas-price-map-field-section">
      #       32
      #     </div>
      #   """
      # }
      {
        xtype: 'map'
        id: 'gmap'
        flex: 1
        useCurrentLocation: no # we handle this ourselves
        mapOptions:
          zoom: 17
          mapTypeControl: no
          zoomControl: no
          streetViewControl: no
          styles: [
            {
              "featureType": "poi"
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            }
          ]
      }
      {
        xtype: 'component'
        id: 'googleMapLinkBlocker'
        flex: 0
      }
      {
        xtype: 'button'
        id: 'centerMapButton'
        flex: 0
        ui: 'plain'
        handler: -> @up().fireEvent 'recenterAtUserLoc'
      }
      {
        xtype: 'component'
        id: 'gasPriceMapDisplay'
        flex: 0
        html: """
          <span class="gas-price-title">Current Price</span>
          <br />
          <span class="gas-price-octane">87 Reg.</span>
          <span class="gas-price-price" id="gas-price-display-87"></span>
          <br />
          <span class="gas-price-octane">91 Pre.</span>
          <span class="gas-price-price" id="gas-price-display-91"></span>
        """
        #   navigator.notification.alert "Our gas price is based on the average price in the area.", (->), "Info"
      }
      {
        xtype: 'component'
        id: 'spacerBetweenMapAndAddress'
        flex: 0
        height: 5
      }
      {
        xtype: 'textfield'
        id: 'requestAddressField'
        flex: 0
        name: 'request_address'
        cls: 'special-input'
        clearIcon: no
        value: 'Updating location...'
        disabled: yes
        listeners:
          initialize: (textField) ->
            textField.element.on 'tap', =>
              textField.setValue ''
              @fireEvent 'addressInputMode'
            true
          keyup: (textField, event) ->
            textField.lastQuery ?= ''
            query = textField.getValue()
            if query isnt textField.lastQuery
              textField.lastQuery = query
              if textField.genSuggTimeout?
                clearTimeout textField.genSuggTimeout
              textField.genSuggTimeout = setTimeout(
                @fireEvent('generateSuggestions'),
                500
              )
            true
      }
      {
        xtype: 'list'
        id: 'autocompleteList'
        flex: 1
        hidden: yes
        scrollable: yes
        itemTpl: """
          {locationName}<br />
          <span class="locationVicinity">{locationVicinity}</span>
        """
        data: [
          {
            locationName: 'Mock Name'
            locationVicinity: 'Mock Vicinity'
          }
        ]
        listeners:
          show: (list) ->
            list.getStore().setData []
          itemtap: (list, index, item, record) ->
            @fireEvent 'updateDeliveryLocAddressByLocArray', record.raw
      }
      {
        xtype: 'container'
        id: 'requestGasButtonContainer'
        cls: [
          'slideable'
        ]
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
            id: 'requestGasButton'
            ui: 'action'
            cls: 'button-pop'
            text: 'Request Gas'
            flex: 0
            disabled: no
            handler: ->
              @up().fireEvent 'initRequestGasForm'
          }
        ]
      }
      
    ]
