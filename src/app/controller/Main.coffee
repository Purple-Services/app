Ext.define 'Purple.controller.Main'
  extend: 'Ext.app.Controller'
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      loginForm: 'loginform'
      requestGasTabContainer: '#requestGasTabContainer'
      mapForm: 'mapform'
      map: '#gmap'
      spacerBetweenMapAndAddress: '#spacerBetweenMapAndAddress'
      requestAddressField: '#requestAddressField'
      requestGasButtonContainer: '#requestGasButtonContainer'
      autocompleteList: '#autocompleteList'
      backToMapButton: '#backToMapButton'
      requestForm: 'requestform'
      requestConfirmationForm: 'requestconfirmationform'
      feedback: 'feedback'
      feedbackTextField: '[ctype=feedbackTextField]'
      feedbackThankYouMessage: '[ctype=feedbackThankYouMessage]'
    control:
      mapForm:
        recenterAtUserLoc: 'recenterAtUserLoc'
      map:
        centerchange: 'adjustDeliveryLocByLatLng'
        maprender: 'initGeocoder'
      requestAddressField:
        generateSuggestions: 'generateSuggestions'
        addressInputMode: 'addressInputMode'
      autocompleteList:
        updateDeliveryLocAddressByLocArray: 'updateDeliveryLocAddressByLocArray'
      backToMapButton:
        mapMode: 'mapMode'
        recenterAtUserLoc: 'recenterAtUserLoc'
      requestGasButtonContainer:
        initRequestGasForm: 'initRequestGasForm'
      requestForm:
        backToMap: 'backToMapFromRequestForm'
        sendRequest: 'sendRequest'
      requestConfirmationForm:
        backToRequestForm: 'backToRequestForm'
        confirmOrder: 'confirmOrder'
      feedback:
        sendFeedback: 'sendFeedback'

  # whether or not the inital map centering has occurred yet
  mapInitiallyCenteredYet: no
  mapInited: no

  launch: ->
    @callParent arguments

    @gpsIntervalRef = setInterval (Ext.bind @updateLatlng, this), 10000
    # and, call it right away
    @updateLatlng()
    # and call it after 2 and 5 seconds so that it hits the google map at a time when it is ready
    setTimeout (Ext.bind @updateLatlng, this), 2000
    setTimeout (Ext.bind @updateLatlng, this), 5000
    # in most cases that is overkill, but on my iPhone 4 the 5 seconds hit is
    # crucial because otherwise you would have to wait 10 seconds
    # (the immediate call is usually before the google map loads)
    # However, on my iPhone 5s the immediate call does work.

    # check if logged in (or if they hacked the localStorage and claim to be)
    if localStorage['purpleUserId']?
      # already logged in
      console.log 'user is logged in with id: ', localStorage['purpleUserId']

    # ga_storage._enableSSL() # TODO security - doesn't seem to actually use SSL
    # ga_storage._setAccount 'UA-55536703-1'
    # ga_storage._setDomain 'none'
    # ga_storage._trackEvent 'main', 'App Launch' # , 'label', 'value'

    navigator.splashscreen.hide()

  updateLatlng: ->
    @updateLatlngBusy ?= no
    if not @updateLatlngBusy
      @updateLatlngBusy = yes
      navigator.geolocation.getCurrentPosition(
        ((position) =>
          @updateLatlngBusy = no
          @lat = position.coords.latitude
          @lng = position.coords.longitude
          if not @mapInitiallyCenteredYet and @mapInited
            @mapInitiallyCenteredYet = true
            @recenterAtUserLoc()
        ),
        (=>
          # console.log "GPS failure callback called."
          @updateLatlngBusy = no),
        {maximumAge: 0, enableHighAccuracy: true}
      )

  initGeocoder: ->
    @geocoder = new google.maps.Geocoder()
    @placesService = new google.maps.places.PlacesService @getMap().getMap()
    @mapInited = true

  adjustDeliveryLocByLatLng: ->
    center = @getMap().getMap().getCenter()
    # might want to send actual 
    @deliveryLocLat = center.lat()
    @deliveryLocLng = center.lng()
    @updateDeliveryLocAddressByLatLng @deliveryLocLat, @deliveryLocLng

  updateDeliveryLocAddressByLatLng: (lat, lng) ->
    latlng = new google.maps.LatLng lat, lng
    @geocoder?.geocode {'latLng': latlng}, (results, status) =>
      if status is google.maps.GeocoderStatus.OK
        if results[1]
          # console.log results
          addressComponents = results[0]['address_components']
          streetAddress = "#{addressComponents[0]['short_name']} #{addressComponents[1]['short_name']}"
          @getRequestAddressField().setValue streetAddress
        else
          console.log 'No results found.'
      else
        console.log 'Geocoder failed due to: ' + status

  mapMode: ->
    @getAutocompleteList().hide()
    @getBackToMapButton().hide()
    @getMap().show()
    @getSpacerBetweenMapAndAddress().show()
    @getRequestGasButtonContainer().show()
    @getRequestAddressField().disable()

  recenterAtUserLoc: ->
    @getMap().getMap().setCenter(
      new google.maps.LatLng @lat, @lng
    )

  addressInputMode: ->
    @getMap().hide()
    @getSpacerBetweenMapAndAddress().hide()
    @getRequestGasButtonContainer().hide()
    @getAutocompleteList().show()
    @getBackToMapButton().show()
    @getRequestAddressField().enable()
    @getRequestAddressField().focus()

  generateSuggestions: ->
    query = @getRequestAddressField().getValue()
    suggestions = new Array()
    Ext.Ajax.request
      url: "https://maps.googleapis.com/maps/api/place/autocomplete/json?types=establishment|geocode&radius=100&location=#{@lat},#{@lng}&sensor=true&key=AIzaSyA0p8k_hdb6m-xvAOosuYQnkDwjsn8NjFg"
      params:
        'input': query
      timeout: 30000
      method: 'GET'
      scope: this
      success: (response) ->
        resp = Ext.JSON.decode response.responseText
        # console.log resp
        if resp.status is 'OK'
          for p in resp.predictions
            isAddress = p.terms[0].value is ""+parseInt(p.terms[0].value)
            locationName = if isAddress then p.terms[0].value + " " + p.terms[1]?.value else p.terms[0].value
            suggestions.push
              'locationName': locationName
              'locationVicinity': p.description.replace locationName+', ', ''
              'locationLat': '0'
              'locationLng': '0'
              'placeId': p.place_id
          @getAutocompleteList().getStore().setData suggestions

  updateDeliveryLocAddressByLocArray: (loc) ->
    @getRequestAddressField().setValue loc['locationName']
    @mapMode()
    # set latlng to zero just in case they press request gas before this func is
    # done. we don't want an old latlng to be in there that doesn't match address
    @deliveryLocLat = 0
    @deliveryLocLng = 0
    @placesService.getDetails {placeId: loc['placeId']}, (place, status) =>
      if status is google.maps.places.PlacesServiceStatus.OK
        latlng = place.geometry.location
        @deliveryLocLat = latlng.lat()
        @deliveryLocLng = latlng.lng()
        @getMap().getMap().setCenter latlng
        @getMap().getMap().setZoom 17
      else
        console.log 'placesService error' + status

  initRequestGasForm: ->
    # are they logged in?
    if not localStorage['purpleUserId']?
      # select the Login view
      @getMainContainer().getItems().getAt(0).select 1, no, no
    else
      deliveryLocName = @getRequestAddressField().getValue()
      @getRequestGasTabContainer().setActiveItem(
        Ext.create 'Purple.view.RequestForm'
      )
      @getRequestForm().setValues(
        lat: @deliveryLocLat
        lng: @deliveryLocLng
        address_street: deliveryLocName
      )

  backToMapFromRequestForm: ->
    @getRequestGasTabContainer().remove(
      @getRequestForm(),
      yes
    )

  backToRequestForm: ->
    @getRequestGasTabContainer().setActiveItem @getRequestForm()
    @getRequestGasTabContainer().remove(
      @getRequestConfirmationForm(),
      yes
    )

  sendRequest: -> # takes you to the confirmation page
    @getRequestGasTabContainer().setActiveItem(
      Ext.create 'Purple.view.RequestConfirmationForm'
    )
    vals = @getRequestForm().getValues()
    vals['gas_price'] = '2.35'
    vals['service_fee'] = '5'
    vals['total_price'] = '45'
    vals['display_time'] = switch vals['time']
      when '< 1 hr' then 'within 1 hour'
      when '< 3 hr' then 'within 3 hours'
    vals['vehicle_id'] = vals['vehicle']
    for v in util.ctl('Vehicles').vehicles
      if v['id'] is vals['vehicle_id']
        vals['vehicle'] = "#{v.year} #{v.make} #{v.model}"
        break
        
    @getRequestConfirmationForm().setValues vals
    if vals['special_instructions'] is ''
      Ext.ComponentQuery.query('#specialInstructionsConfirmationLabel')[0].hide()
      Ext.ComponentQuery.query('#specialInstructionsConfirmation')[0].hide()

  confirmOrder: ->
    console.log 'Confirm Order', @getRequestConfirmationForm().getValues()

    vals = @getRequestConfirmationForm().getValues()
    vals['gas_price'] = parseFloat(vals['gas_price'].replace('$',''))
    vals['service_fee'] = parseFloat(vals['service_fee'].replace('$',''))
    vals['total_price'] = parseFloat(vals['total_price'].replace('$',''))
    
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}orders/add"
      params: Ext.JSON.encode
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        order: vals
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          util.ctl('Menu').selectOption 3 # Orders tab
          util.ctl('Orders').loadOrdersList yes
          @getRequestGasTabContainer().setActiveItem @getMapForm()
          @getRequestGasTabContainer().remove(
            @getRequestConfirmationForm(),
            yes
          )
          @getRequestGasTabContainer().remove(
            @getRequestForm(),
            yes
          )
        else
          Ext.Msg.alert 'Error', response.message, (->)
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  sendFeedback: ->
    params =
      text: @getFeedbackTextField().getValue()
    if util.ctl('Account').isUserLoggedIn()
      params['user_id'] = localStorage['purpleUserId']
      params['token'] = localStorage['purpleToken']
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}feedback/send"
      params: Ext.JSON.encode params
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @getFeedbackTextField().setValue ''
          util.flashComponent @getFeedbackThankYouMessage()
        else
          Ext.Msg.alert 'Error', response.message, (->)
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response
