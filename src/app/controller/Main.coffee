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
      invite: 'invite'
      inviteTextField: '[ctype=inviteTextField]'
      inviteThankYouMessage: '[ctype=inviteThankYouMessage]'
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
      invite:
        sendInvites: 'sendInvites'

  # whether or not the inital map centering has occurred yet
  mapInitiallyCenteredYet: no
  mapInited: no

  # only used if logged in as courier
  courierPingIntervalRef: null

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

    # Uncomment this for customer app, but courier doesn't need it
    ga_storage._enableSSL() # doesn't seem to actually use SSL?
    ga_storage._setAccount 'UA-61762011-1'
    ga_storage._setDomain 'none'
    ga_storage._trackEvent 'main', 'App Launch' # , 'label', 'value'

    navigator.splashscreen?.hide()

    if util.ctl('Account').hasPushNotificationsSetup()
      @setUpPushNotifications()
      # seems like overkill here (esp. since these cause ajax calls)
      setTimeout (Ext.bind @setUpPushNotifications, this), 5000

  setUpPushNotifications: ->
    if Ext.os.name is "iOS"
      window.plugins?.pushNotification?.register(
        (Ext.bind @registerDeviceForPushNotifications, this),
        ((error) -> alert "error: " + error),
        {
          "badge": "true"
          "sound": "true"
          "alert": "true"
          "ecb": "onNotificationAPN"
        }
      )
    else
      # must be Android
      window.plugins?.pushNotification?.register(
        ((result) ->),
        ((error) -> alert "error: " + error),
        {
          "senderID": util.GCM_SENDER_ID
          "ecb": "onNotification"
        }
      )

  # This is happening pretty often: initial setup and then any app start
  # and logins. Need to look into this later. I want to make sure it is
  # registered but I don't think we need to call add-sns ajax so often.
  registerDeviceForPushNotifications: (cred, pushPlatform = "apns") ->
    # cred for APNS (apple) is the device token
    # for GCM (android) it is regid
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/add-sns"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        cred: cred
        push_platform: pushPlatform
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          localStorage['purpleUserHasPushNotificationsSetUp'] = "true"
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        console.log response_obj

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
        if results[0]?['address_components']?
          addressComponents = results[0]['address_components']
          streetAddress = "#{addressComponents[0]['short_name']} #{addressComponents[1]['short_name']}"
          @getRequestAddressField().setValue streetAddress
          # find the address component that contains the zip code
          for c in addressComponents
            for t in c.types
              if t is "postal_code"
                @deliveryAddressZipCode = c['short_name']
        # else
        #   console.log 'No results found.'
      # else
      #   console.log 'Geocoder failed due to: ' + status

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
    ga_storage._trackEvent 'ui', 'Address Text Input Mode'

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
        # find the address component that contains the zip code
        for c in place.address_components
          for t in c.types
            if t is "postal_code"
              @deliveryAddressZipCode = c['short_name']
        @deliveryLocLat = latlng.lat()
        @deliveryLocLng = latlng.lng()
        @getMap().getMap().setCenter latlng
        @getMap().getMap().setZoom 17
      # else
      #   console.log 'placesService error' + status

  initRequestGasForm: ->
    ga_storage._trackEvent 'ui', 'Request Gas Button Pressed'
    deliveryLocName = @getRequestAddressField().getValue()
    if deliveryLocName is @getRequestAddressField().getInitialConfig().value
      return # just return, it hasn't loaded the location yet
    if not (util.ctl('Account').isUserLoggedIn() and util.ctl('Account').isCompleteAccount())
      # select the Login view
      @getMainContainer().getItems().getAt(0).select 1, no, no
    else
      # send to request gas form, but first get availbility from disptach system
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}dispatch/availability"
        params: Ext.JSON.encode
          version: util.VERSION_NUMBER
          user_id: localStorage['purpleUserId']
          token: localStorage['purpleToken']
          lat: @deliveryLocLat
          lng: @deliveryLocLng
          zip_code: @deliveryAddressZipCode
        headers:
          'Content-Type': 'application/json'
        timeout: 30000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            availabilities = response.availabilities
            # first, see if there are any gallons available at all
            totalGallons = availabilities.reduce (a, b) ->
              a.gallons + b.gallons
            # and, are there any time options available
            totalNumOfTimeOptions = availabilities.reduce (a, b) ->
              Object.keys(a.times).length + Object.keys(b.times).length
            if totalGallons < util.MINIMUM_GALLONS or totalNumOfTimeOptions is 0
              navigator.notification.alert response["unavailable-reason"], (->), "Unavailable"
            else
              @getRequestGasTabContainer().setActiveItem(
                Ext.create 'Purple.view.RequestForm',
                  availabilities: availabilities
              ) 
              @getRequestForm().setValues(
                lat: @deliveryLocLat
                lng: @deliveryLocLng
                address_street: deliveryLocName
                address_zip: @deliveryAddressZipCode
              )
          else
            navigator.notification.alert response.message, (->), "Error"
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          console.log response_obj

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
    availabilities = @getRequestForm().config.availabilities
    gasType = util.ctl('Vehicles').getVehicleById(vals['vehicle']).gas_type
    for a in availabilities
      if a['octane'] is gasType
        availability = a
        break

    gasPrice = availability.price_per_gallon
    serviceFee = availability.times[vals['time']]['service_fee']
    vals['gas_price'] = "" + util.centsToDollars(
      gasPrice
    )
    vals['service_fee'] = "" + util.centsToDollars(
      serviceFee
    )
    vals['total_price'] = "" + util.centsToDollars(
      parseFloat(gasPrice) * parseFloat(vals['gallons']) +
      parseFloat(serviceFee)
    )
    vals['display_time'] = availability.times[vals['time']]['text']
    vals['vehicle_id'] = vals['vehicle']
    for v in util.ctl('Vehicles').vehicles
      if v['id'] is vals['vehicle_id']
        vals['vehicle'] = "#{v.year} #{v.make} #{v.model}"
        break

    @getRequestConfirmationForm().setValues vals
    if vals['special_instructions'] is ''
      Ext.ComponentQuery.query('#specialInstructionsConfirmationLabel')[0].hide()
      Ext.ComponentQuery.query('#specialInstructionsConfirmation')[0].hide()
      Ext.ComponentQuery.query('#addressStreetConfirmation')[0].removeCls 'bottom-margin'

  confirmOrder: ->
    if not util.ctl('Account').hasDefaultPaymentMethod()
      # select the Account view
      @getMainContainer().getItems().getAt(0).select 2, no, no
      pmCtl = util.ctl('PaymentMethods')
      if not pmCtl.getPaymentMethods()?
        pmCtl.accountPaymentMethodFieldTap()
      if pmCtl.getEditPaymentMethodForm()?
        # there already exists a payment method edit form, just go to that
        pmCtl.getAccountTabContainer().setActiveItem pmCtl.getEditPaymentMethodForm()
      else
        pmCtl.showEditPaymentMethodForm()
      pmCtl.getEditPaymentMethodForm().config.saveChangesCallback = ->
        pmCtl.backToAccount()
        util.ctl('Menu').selectOption 0
    else
      vals = @getRequestConfirmationForm().getValues()
      # prices are finally given in cents
      vals['gas_price'] = parseInt(
        vals['gas_price'].replace('$','').replace('.','')
      )
      vals['service_fee'] = parseInt(
        vals['service_fee'].replace('$','').replace('.','')
      )
      vals['total_price'] = parseInt(
        vals['total_price'].replace('$','').replace('.','')
      )
      
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}orders/add"
        params: Ext.JSON.encode
          version: util.VERSION_NUMBER
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
            # set up push notifications if they arent set up
            if not util.ctl('Account').hasPushNotificationsSetup()
              @setUpPushNotifications()
          else
            navigator.notification.alert response.message, (->), "Error"
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          console.log response

  sendFeedback: ->
    params =
      version: util.VERSION_NUMBER
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
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  sendInvites: ->
    params =
      version: util.VERSION_NUMBER
      email: @getInviteTextField().getValue()
    if util.ctl('Account').isUserLoggedIn()
      params['user_id'] = localStorage['purpleUserId']
      params['token'] = localStorage['purpleToken']
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}invite/send"
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
          @getInviteTextField().setValue ''
          util.flashComponent @getInviteThankYouMessage()
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  initCourierPing: ->
    window.plugin?.backgroundMode.enable()
    @courierPingIntervalRef = setInterval (Ext.bind @courierPing, this), 10000

  killCourierPing: ->
    if @courierPingIntervalRef?
      clearInterval @courierPingIntervalRef

  courierPing: ->
    @errorCount ?= 0
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}courier/ping"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        lat: @lat
        lng: @lng
        gallons:
          87: localStorage['purpleCourierGallons87']
          91: localStorage['purpleCourierGallons91']
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        response = Ext.JSON.decode response_obj.responseText
        if not response.success
          @errorCount++
          if @errorCount > 10
            @errorCount = 0
            navigator.notification.alert "Unable to ping dispatch center.", (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        @errorCount++
        if @errorCount > 10
          @errorCount = 0
          navigator.notification.alert "Unable to ping dispatch center. Problem with internet connectivity.", (->), "Error"
