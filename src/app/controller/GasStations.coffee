Ext.define 'Purple.controller.GasStations',
  extend: 'Ext.app.Controller'
  config:
    refs:
      findGasButtonContainer: '[ctype=findGasButtonContainer]'
      recommendedGasStation: '[ctype=recommendedGasStation]'
      blacklistGasStationButtonContainer: '[ctype=blacklistGasStationButtonContainer]'
      gasStationTip: '[ctype=gasStationTip]'
    control:
      findGasButtonContainer:
        getGasStation: 'getGasStation'
      blacklistGasStationButtonContainer:
        blacklistGasStation: 'blacklistGasStation'

  launch: ->

  getGasStation: ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "gasStation.json"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        gasStation = @getRecommendedGasStation()
        if response.success
          gasStation.removeAll yes, yes
          gasStation.add
            xtype: 'textfield'
            flex: 0
            label: """
              <span class="maintext">#{response.brand}</span>
              <br /><span class="subtext">#{response.address_street}</span>
            """
            labelWidth: '100%'
            cls: [
              'bottom-margin'
              'gas-station-item'
            ]
            disabled: yes
            listeners:
              initialize: (field) ->
                field.element.on 'tap', ->
                  window.location.href = "comgooglemaps://?daddr=#{response.lat + "," + response.lng}&directionsmode=driving"
          @getBlacklistGasStationButtonContainer().show()
          @getGasStationTip().show()
        else
          @getGasStationTip().hide()
          @getBlacklistGasStationButtonContainer().hide()
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  blacklistGasStation: ->
    console.log 'blacklist working'
