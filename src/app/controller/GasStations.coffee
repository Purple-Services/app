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
    enrouteOrLessOrders = (
      util.ctl('Orders').getActiveOrders().filter (o) ->
        o.status isnt 'servicing'
    )
    options = []
    for o, order of enrouteOrLessOrders
      options.push "On the way to #{order.address_street}"
    options.push "Near Me"

    window.plugins.actionsheet.show(
      {
        'title': "Find a gas station..."
        'buttonLabels': options
        'androidEnableCancelButton': true
        'addCancelButtonWithLabel': 'Cancel'
      },
      ((index) =>
        if index is 0 or index is options.length + 1 # Cancel
          return
        else if index is options.length # Near Me
          @getGasStationsFromServer()
        else
          destOrder = enrouteOrLessOrders[index - 1]
          @getGasStationsFromServer destOrder.lat, destOrder.lng
      )
    )
    
  getGasStationsFromServer: (destLat = null, destLng = null) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: 'This can take a while...'
    navigator.geolocation?.getCurrentPosition(
      ((position) =>
        util.ctl('Main').positionAccuracy = position.coords.accuracy
        util.ctl('Main').lat = position.coords.latitude
        util.ctl('Main').lng = position.coords.longitude
        util.ctl('Main').positionAccuracy = position.coords.accuracy
        Ext.Ajax.request
          url: "#{util.WEB_SERVICE_BASE_URL}courier/gas-stations/find"
          params: Ext.JSON.encode
            version: util.VERSION_NUMBER
            user_id: localStorage['purpleUserId']
            token: localStorage['purpleToken']
            lat: util.ctl('Main').lat
            lng: util.ctl('Main').lng
            dest_lat: destLat
            dest_lng: destLng
            position_accuracy: util.ctl('Main').positionAccuracy
          headers:
            'Content-Type': 'application/json'
          timeout: 40000
          method: 'POST'
          scope: this
          success: (response_obj) ->
            response = Ext.JSON.decode response_obj.responseText
            gasStation = @getRecommendedGasStation()
            if response.success
              gasStation.removeAll yes, yes
              gasStation.add
                xtype: 'textfield'
                flex: 0
                label: """
                  <span class="maintext">#{response.brand}</span>
                  <br /><span class="subtext">#{response.address_street.split(',')[0]}</span>
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
                      window.location.href = util.googleMapsDeepLink "?daddr=#{response.lat + "," + response.lng}&directionsmode=driving"
              @getBlacklistGasStationButtonContainer().config.stationId = response.id
              @getBlacklistGasStationButtonContainer().show()
              @getGasStationTip().show()
            else
              @getGasStationTip().hide()
              @getBlacklistGasStationButtonContainer().hide()
              util.alert response.message, "Error"
            Ext.Viewport.setMasked false
          failure: (response_obj) ->
            Ext.Viewport.setMasked false
            response = Ext.JSON.decode response_obj.responseText
            console.log response
      ),
      (=>
        util.alert "Please ensure GPS is allowed for the Purple Courier app.", "Unable to get your location"
        Ext.Viewport.setMasked false),
      {maximumAge: 0, enableHighAccuracy: true}
    )

  blacklistGasStation: ->
    blacklistReasons = [
      "Permanently closed"     # until 1999999999
      "Not open right now"     # until + 43200    (+ 12 hours)
      "Long line"              # until + 10800    (+ 3 hours)
      "Gas card not accepted"  # until 1999999999
      "Price is too high"      # until + 864000   (+ 10 days)
      "Other"                  # until 1999999999
    ]
    stationId = @getBlacklistGasStationButtonContainer().config.stationId
    
    window.plugins.actionsheet.show(
      {
        'title': "What's wrong with this station?"
        'buttonLabels': blacklistReasons
        'androidEnableCancelButton': true
        'addCancelButtonWithLabel': 'Cancel'
      },
      ((index) =>
        if index isnt 0 and index isnt blacklistReasons.length + 1
          # not the cancel button
          @blacklistGasStationOnServer stationId, blacklistReasons[index - 1]
      )
    )

  blacklistGasStationOnServer: (stationId, reason = "Other") ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}courier/gas-stations/blacklist"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        station_id: stationId
        reason: reason
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          util.alert response.message, (response.message_title or "Info")
          @getRecommendedGasStation().removeAll yes, yes
          @getGasStationTip().hide()
          @getBlacklistGasStationButtonContainer().hide()
        else
          util.alert response.message, (response.message_title or "Error")
        Ext.Viewport.setMasked false
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response
