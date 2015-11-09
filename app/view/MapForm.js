Ext.define('Purple.view.MapForm', {
  extend: 'Ext.Container',
  xtype: 'mapform',
  requires: ['Ext.form.*', 'Ext.field.*', 'Ext.Button'],
  config: {
    layout: 'vbox',
    height: '100%',
    cls: 'offwhite-bg',
    scrollable: false,
    submitOnAction: false,
    listeners: {
      painted: function() {
        var mapDom, styleRule;
        mapDom = Ext.get('gmap');
        styleRule = "<style>\n  #gmap:after {\n    top: " + (mapDom.getHeight() / 2) + "px;\n  }\n</style>";
        return Ext.DomHelper.append(mapDom, styleRule);
      }
    },
    items: [
      {
        xtype: 'map',
        id: 'gmap',
        flex: 1,
        useCurrentLocation: false,
        mapOptions: {
          zoom: 17,
          mapTypeControl: false,
          zoomControl: false,
          streetViewControl: false,
          styles: [
            {
              "featureType": "poi",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            }
          ]
        }
      }, {
        xtype: 'component',
        id: 'googleMapLinkBlocker',
        flex: 0
      }, {
        xtype: 'button',
        id: 'centerMapButton',
        flex: 0,
        ui: 'plain',
        handler: function() {
          return this.up().fireEvent('recenterAtUserLoc');
        }
      }, {
        xtype: 'component',
        id: 'gasPriceMapDisplay',
        flex: 0,
        html: "<span class=\"gas-price-title\">Current Price</span>\n<br />\n<span class=\"gas-price-octane\">87 Reg.</span>\n<span class=\"gas-price-price\" id=\"gas-price-display-87\"></span>\n<br />\n<span class=\"gas-price-octane\">91 Pre.</span>\n<span class=\"gas-price-price\" id=\"gas-price-display-91\"></span>"
      }, {
        xtype: 'component',
        id: 'spacerBetweenMapAndAddress',
        flex: 0,
        height: 5
      }, {
        xtype: 'textfield',
        id: 'requestAddressField',
        flex: 0,
        name: 'request_address',
        cls: 'special-input',
        clearIcon: false,
        value: 'Updating location...',
        disabled: true,
        listeners: {
          initialize: function(textField) {
            textField.element.on('tap', (function(_this) {
              return function() {
                textField.setValue('');
                return _this.fireEvent('addressInputMode');
              };
            })(this));
            return true;
          },
          keyup: function(textField, event) {
            var query;
            if (textField.lastQuery == null) {
              textField.lastQuery = '';
            }
            query = textField.getValue();
            if (query !== textField.lastQuery) {
              textField.lastQuery = query;
              if (textField.genSuggTimeout != null) {
                clearTimeout(textField.genSuggTimeout);
              }
              textField.genSuggTimeout = setTimeout(this.fireEvent('generateSuggestions'), 500);
            }
            return true;
          }
        }
      }, {
        xtype: 'list',
        id: 'autocompleteList',
        flex: 1,
        hidden: true,
        scrollable: true,
        itemTpl: "{locationName}<br />\n<span class=\"locationVicinity\">{locationVicinity}</span>",
        data: [
          {
            locationName: 'Mock Name',
            locationVicinity: 'Mock Vicinity'
          }
        ],
        listeners: {
          show: function(list) {
            return list.getStore().setData([]);
          },
          itemtap: function(list, index, item, record) {
            return this.fireEvent('updateDeliveryLocAddressByLocArray', record.raw);
          }
        }
      }, {
        xtype: 'container',
        id: 'requestGasButtonContainer',
        cls: ['slideable'],
        flex: 0,
        height: 110,
        padding: '0 0 5 0',
        layout: {
          type: 'vbox',
          pack: 'center',
          align: 'center'
        },
        items: [
          {
            xtype: 'button',
            ui: 'action',
            cls: 'button-pop',
            text: 'Request Gas',
            flex: 0,
            handler: function() {
              return this.up().fireEvent('initRequestGasForm');
            }
          }
        ]
      }
    ]
  }
});
