Ext.define 'Purple.controller.GasStations',
  extend: 'Ext.app.Controller'
  config:
    refs:
      findGasButtonContainer: '[ctype=findGasButtonContainer]'
      blacklistGasStationButtonContainer: '[ctype=blacklistGasStationButtonContainer]'
    control:
      findGasButtonContainer:
        getGasStation: 'getGasStation'
      blacklistGasStationButtonContainer:
        blacklistGasStation: 'blacklistGasStation'

  launch: ->

  getGasStation: ->
    console.log localStorage['purpleUserId']
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/edit"
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
        if response.success
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  blacklistGasStation: ->
    alert 'blacklist'