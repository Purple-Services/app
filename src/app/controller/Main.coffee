Ext.define 'Purple.controller.Main'
  extend: 'Ext.app.Controller'
  requires: [
    'Purple.view.MapForm'
    'Purple.view.RequestForm'
  ]
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      backButton: '[ctype=backButton]'
    control:
      patientWelcome:
        patientWelcomeStart: 'patientWelcomeStart'
        patientWelcomeAbort: 'patientWelcomeAbort'

  launch: ->
    @callParent arguments

    #requestForm = Ext.create 'Purple.view.RequestForm'
    mapForm = Ext.create 'Purple.view.MapForm'
    @getMainContainer().add [
      mapForm
    ]

    @gpsIntervalRef = setInterval (Ext.bind @updateLatlng, this), 10000

    # ga_storage._enableSSL() # TODO security - doesn't seem to actually use SSL
    # ga_storage._setAccount 'UA-55536703-1'
    # ga_storage._setDomain 'none'
    # ga_storage._trackEvent 'main', 'App Launch' # , 'label', 'value'

  updateLatlng: ->
    @updateLatlngBusy ?= no
    if not @updateLatlngBusy
      @updateLatlngBusy = yes
      navigator.geolocation.getCurrentPosition(
        ((position) =>
          @updateLatlngBusy = no
          @latlng = "#{position.coords.latitude},#{position.coords.longitude}"),
        (=>
          # console.log "GPS failure callback called."
          @updateLatlngBusy = no),
        {maximumAge: 0, enableHighAccuracy: true}
      )
