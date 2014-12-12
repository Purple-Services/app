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
      menuButton: '[ctype=menuButton]'
      mapForm: 'mapform'
      map: '#gmap'
      requestAddressField: '#requestAddressField'
    control:
      menuButton:
        menuButtonTap: 'menuButtonHandler'
      map:
        centerchange: 'adjustDeliveryLocByLatLng'
        maprender: 'initGeocoder'

  launch: ->
    @callParent arguments

    #requestForm = Ext.create 'Purple.view.RequestForm'
    # mapForm = Ext.create 'Purple.view.MapForm'
    # @getMainContainer().add [
    #   mapForm
    # ]

    @gpsIntervalRef = setInterval (Ext.bind @updateLatlng, this), 10000
    # and, call it right away
    @updateLatlng()

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
          latLngWasSet = @lat?
          @lat = position.coords.latitude
          @lng = position.coords.longitude
          if not latLngWasSet
            @getMap().getMap().setCenter(
              new google.maps.LatLng @lat, @lng
            )
        ),
        (=>
          # console.log "GPS failure callback called."
          @updateLatlngBusy = no),
        {maximumAge: 0, enableHighAccuracy: true}
      )

  menuButtonHandler: ->
    @getMainContainer().toggleContainer()

  initGeocoder: ->
    console.log 'in here', google, google.maps
    @geocoder = new google.maps.Geocoder()

  adjustDeliveryLocByLatLng: ->
    center = @getMap().getMap().getCenter()
    # might want to send actual 
    @deliveryLocLat = center.lat()
    @deliveryLocLng = center.lng()
    @updateDeliveryLocAddressByLatLng @deliveryLocLat, @deliveryLocLng

  updateDeliveryLocAddressByLatLng: (lat, lng) ->
    latlng = new google.maps.LatLng lat, lng
    console.log @geocoder
    @geocoder.geocode {'latLng': latlng}, (results, status) =>
      if status is google.maps.GeocoderStatus.OK
        if results[1]
          console.log results
          addressComponents = results[0]['address_components']
          streetAddress = "#{addressComponents[0]['short_name']} #{addressComponents[1]['short_name']}"
          @getRequestAddressField().setValue streetAddress
        else
          console.log 'No results found.'
      else
        console.log 'Geocoder failed due to: ' + status
