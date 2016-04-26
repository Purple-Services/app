Ext.define 'Purple.controller.Main',
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
      gasPriceMapDisplay: '#gasPriceMapDisplay'
      requestAddressField: '#requestAddressField'
      requestGasButtonContainer: '#requestGasButtonContainer'
      requestGasButton: '#requestGasButton'
      autocompleteList: '#autocompleteList'
      requestForm: 'requestform'
      requestConfirmationForm: 'requestconfirmationform'
      feedback: 'feedback'
      feedbackTextField: '[ctype=feedbackTextField]'
      feedbackThankYouMessage: '[ctype=feedbackThankYouMessage]'
      invite: 'invite'
      inviteTextField: '[ctype=inviteTextField]'
      inviteThankYouMessage: '[ctype=inviteThankYouMessage]'
      freeGasField: '#freeGasField'
      discountField: '#discountField'
      couponCodeField: '#couponCodeField'
      totalPriceField: '#totalPriceField'
      homeAddressContainer: '#homeAddressContainer'
      workAddressContainer: '#workAddressContainer'
      accountHomeAddress: '#accountHomeAddress'
      accountWorkAddress: '#accountWorkAddress'
      addHomeAddressContainer: '#addHomeAddressContainer'
      addWorkAddressContainer: '#addWorkAddressContainer'
      addHomeAddress: '#addHomeAddress'
      addWorkAddress: '#addWorkAddress'
      removeHomeAddressContainer: '#removeHomeAddressContainer'
      removeWorkAddressContainer: '#removeWorkAddressContainer'
      removeHomeAddress: '#removeHomeAddress'
      removeWorkAddress: '#removeWorkAddress'
      centerMapButton: '#centerMapButton'
    control:
      mapForm:
        recenterAtUserLoc: 'recenterAtUserLoc'
        changeHomeAddress: 'changeHomeAddress'
        changeWorkAddress: 'changeWorkAddress'
      map:
        dragstart: 'dragStart'
        boundchange: 'boundChanged'
        idle: 'idle'
        centerchange: 'adjustDeliveryLocByLatLng'
        maprender: 'initGeocoder'
      requestAddressField:
        generateSuggestions: 'generateSuggestions'
        addressInputMode: 'addressInputMode'
        showLogin: 'showLogin'
      autocompleteList:
        handleAutoCompleteListTap: 'handleAutoCompleteListTap'
      requestGasButtonContainer:
        initRequestGasForm: 'requestGasButtonPressed'
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
      accountHomeAddress:
        initialize: 'initAccountHomeAddress'
      accountWorkAddress:
        initialize: 'initAccountWorkAddress'
      addHomeAddress:
        initialize: 'initAddHomeAddress'
      addWorkAddress:
        initialize: 'initAddWorkAddress'
      removeHomeAddress:
        initialize: 'initRemoveHomeAddress'
      removeWorkAddress:
        initialize: 'initRemoveWorkAddress'
        
  # whether or not the inital map centering has occurred yet
  mapInitiallyCenteredYet: no
  mapInited: no

  # only used if logged in as courier
  courierPingIntervalRef: null

  launch: ->
    @callParent arguments

    localStorage['lastCacheVersionNumber'] = util.VERSION_NUMBER

    # COURIER APP ONLY
    # Remember to comment/uncomment the setTimeout script in index.html
    
    # clearTimeout window.courierReloadTimer
    
    # END COURIER APP ONLY

    @gpsIntervalRef = setInterval (Ext.bind @updateLatlng, this), 5000

    # CUSTOMER APP ONLY
    if VERSION is "PROD"
      ga_storage?._enableSSL() # doesn't seem to actually use SSL?
      ga_storage?._setAccount 'UA-61762011-1'
      ga_storage?._setDomain 'none'
      ga_storage?._trackEvent 'main', 'App Launch', "Platform: #{Ext.os.name}"

    analytics?.load util.SEGMENT_WRITE_KEY
    if util.ctl('Account').isUserLoggedIn()
      analytics?.identify localStorage['purpleUserId']
      # segment says you 'have' to call analytics.page() at some point
      # it doesn't seem to actually matter though
    analytics?.track 'App Launch',
      platform: Ext.os.name
    analytics?.page 'Map'
    # END OF CUSTOMER APP ONLY
    
    navigator.splashscreen?.hide()

    if util.ctl('Account').hasPushNotificationsSetup()
      # this is just a re-registering locally, not an initial setup
      # we don't want to do the initial setup because they may not be
      # logged in
      setTimeout (Ext.bind @setUpPushNotifications, this), 4000

    @checkGoogleMaps()

    document.addEventListener("resume", (Ext.bind @onResume, this), false)

    @locationNotification = 0

    @androidHighAccuracyNotificationActive = false

  onResume: ->
    if util.ctl('Account').isCourier() and Ext.os.name is "iOS"
      cordova.plugins.diagnostic?.getLocationAuthorizationStatus(
        ((status) =>
          if status isnt "authorized_always" and @locationNotification < 3
            navigator.notification.alert "Please make sure that the app's Location settings on your device is set to 'Always'.", (->), 'Warning'
            @locationNotification++
        ), 
        (=> console.log "Error getting location authorization status")
      )
    if util.ctl('Account').isUserLoggedIn()
      # this is causing it to happen very often, probably want to change that
      # so it only happens when there is a change in user's settings
      @setUpPushNotifications()
      util.ctl('Orders').refreshOrdersAndOrdersList()

  checkGoogleMaps: ->
    if not google?.maps?
      currentDate = new Date()
      today = "#{currentDate.getMonth()}/#{currentDate.getDate()}/#{currentDate.getFullYear()}"
      localStorage['reloadAttempts'] ?= '0'
      if not localStorage['currentDate']? or today isnt localStorage['currentDate']
        localStorage['currentDate'] = today
        localStorage['reloadAttempts'] = '0'
        analytics?.track 'Google Maps Failed to Load'
      if localStorage['reloadAttempts'] isnt '3'
        localStorage['reloadAttempts'] = (parseInt(localStorage['reloadAttempts']) + 1).toString()
        navigator.splashscreen?.show()
        window.location.reload()
      else
        navigator.notification.confirm 'Please try restarting the application. If the problem persists, contact support@purpledelivery.com.', @connectionStatusConfirmation, 'Connection Problem', ['OK', 'Reload']
        
  connectionStatusConfirmation: (index) ->
    if index is 2
      navigator.splashscreen.show()
      window.location.reload()

  setUpPushNotifications: (alertIfDisabled) ->
    if Ext.os.name is "iOS"
      if alertIfDisabled
        @pushNotificationEnabled = false
        setTimeout (=> 
          if not @pushNotificationEnabled
            navigator.notification.alert 'Your push notifications are turned off. If you want to receive order updates, you can turn them on in your phone settings.', (->), "Reminder"
          ), 1500 
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
      if alertIfDisabled
        @pushNotificationEnabled = false
        setTimeout (=> 
          if not @pushNotificationEnabled
            navigator.notification.alert 'Your push notifications are turned off. If you want to receive order updates, you can turn them on in your phone settings.', (->), "Reminder"
          ), 1500 
      window.plugins?.pushNotification?.register(
        ((result) => @pushNotificationEnabled = true),
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
    @pushNotificationEnabled = true
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

  checkAndroidLocationSettings: ->
    if Ext.os.name is 'Android'
      if util.ctl('Account').isCourier() or @locationNotification < 1
        cordova.plugins.diagnostic?.getLocationMode(
          ((locationMode) =>
            if locationMode isnt 'high_accuracy' and @androidHighAccuracyNotificationActive is false
              @androidHighAccuracyNotificationActive = true
              cordova.plugins.locationAccuracy.request(
                (=>
                  @androidHighAccuracyNotificationActive = false
                  window.location.reload()), 
                (=> 
                  @androidHighAccuracyNotificationActive = false
                  if not util.ctl('Account').isCourier()
                    @centerUsingIpAddress()
                    navigator.notification.alert "Certain features of the application may not work properly. Please restart the application and enable high accuracy to use all the features.", (->), "Location Settings"
                  ), 
                cordova.plugins.locationAccuracy.REQUEST_PRIORITY_HIGH_ACCURACY
              )
              @locationNotification++
          ), 
          (=> console.log 'Diagnostics plugin error')
        )

  updateLatlng: ->
    @checkAndroidLocationSettings()
    @updateLatlngBusy ?= no
    if not @updateLatlngBusy
      @updateLatlngBusy = yes
      navigator.geolocation?.getCurrentPosition(
        ((position) =>
          @positionAccuracy = position.coords.accuracy
          @geolocationAllowed = true
          @lat = position.coords.latitude
          @lng = position.coords.longitude
          if not @mapInitiallyCenteredYet and @mapInited
            @mapInitiallyCenteredYet = true
            @recenterAtUserLoc()
          @updateLatlngBusy = no
        ),
        (=>
          # console.log "GPS failure callback called"
          if not @geolocationAllowed? or @geolocationAllowed is true
            @centerUsingIpAddress()
            @geolocationAllowed = false
          if not localStorage['gps_not_allowed_event_sent']?
            analytics?.track 'GPS Not Allowed'
            localStorage['gps_not_allowed_event_sent'] = 'yes'
          @updateLatlngBusy = no),
        {maximumAge: 0, enableHighAccuracy: true}
      )
  
  centerUsingIpAddress: ->
    # This works but cannot be used for commercial purposes unless we pay for it. Currently exploring other options.
    # Ext.Ajax.request
    #   url: "http://ip-api.com/json"
    #   headers:
    #     'Content-Type': 'application/json'
    #   timeout: 5000
    #   method: 'GET'
    #   scope: this
    #   success: (response_obj) ->
    #     response = Ext.JSON.decode response_obj.responseText
    #     @getMap().getMap().setCenter(
    #       new google.maps.LatLng response.lat, response.lon
    #       )
    #   failure: (response_obj) ->
    @getMap().getMap().setCenter(
      new google.maps.LatLng 34.0507177, -118.43757779999999
      )

  initGeocoder: ->
    # this is called on maprender, so let's make sure we have user loc centered
    @updateLatlng()
    if google? and google.maps? and @getMap()?
      @geocoder = new google.maps.Geocoder()
      @placesService = new google.maps.places.PlacesService @getMap().getMap()
      @mapInited = true
    else
      navigator.notification.alert "Internet connection problem. Please try closing the app and restarting it.", (->), "Connection Error"

  dragStart: ->
    @lastDragStart = new Date().getTime() / 1000
    @getRequestGasButton().setDisabled yes
    @getCenterMapButton().hide()

  boundChanged: ->
    @getRequestGasButton().setDisabled yes

  idle: ->
    currentTime = new Date().getTime() / 1000
    if currentTime - @lastDragStart > 0.3
      @getCenterMapButton().show()

  adjustDeliveryLocByLatLng: ->
    center = @getMap().getMap().getCenter()
    # might want to send actual 
    @deliveryLocLat = center.lat()
    @deliveryLocLng = center.lng()
    @updateDeliveryLocAddressByLatLng @deliveryLocLat, @deliveryLocLng

  updateMapWithAddressComponents: (address) ->
    if address[0]?['address_components']?
      addressComponents = address[0]['address_components']
      streetAddress = "#{addressComponents[0]['short_name']} #{addressComponents[1]['short_name']}"
      @getRequestAddressField().setValue streetAddress
      # find the address component that contains the zip code
      for c in addressComponents
        for t in c.types
          if t is "postal_code"
            @deliveryAddressZipCode = c['short_name']
            if not localStorage['gps_not_allowed_event_sent'] and not localStorage['first_launch_loc_sent']?
              # this means that this is the zip code of the location
              # where they first launched the app and they allowed GPS
              analytics?.track 'First Launch Location',
                street_address: streetAddress
                zip_code: @deliveryAddressZipCode
              localStorage['first_launch_loc_sent'] = 'yes'
      @busyGettingGasPrice ?= no
      if not @busyGettingGasPrice
        @busyGettingGasPrice = yes
        Ext.Ajax.request
          url: "#{util.WEB_SERVICE_BASE_URL}dispatch/gas-prices"
          params: Ext.JSON.encode
            version: util.VERSION_NUMBER
            zip_code: @deliveryAddressZipCode
          headers:
            'Content-Type': 'application/json'
          timeout: 30000
          method: 'POST'
          scope: this
          success: (response_obj) ->
            @getRequestGasButton().setDisabled no
            response = Ext.JSON.decode response_obj.responseText
            if response.success
              prices = response.gas_prices
              Ext.get('gas-price-display-87').setText(
                "$#{util.centsToDollars prices["87"]}"
              )
              Ext.get('gas-price-display-91').setText(
                "$#{util.centsToDollars prices["91"]}"
              )
            @busyGettingGasPrice = no
          failure: (response_obj) ->
            @busyGettingGasPrice = no
            console.log response_obj

  updateDeliveryLocAddressByLatLng: (lat, lng) ->
    if @bypassUpdateDeliveryLocAddressByLatLng? and @bypassUpdateDeliveryLocAddressByLatLng
      @bypassUpdateDeliveryLocAddressByLatLng = false
      return
    else
      latlng = new google.maps.LatLng lat, lng
      @geocoder?.geocode {'latLng': latlng}, (results, status) =>
        if @geocodeTimeout?
          clearTimeout @geocodeTimeout
          @geocodeTimeout = null
        if status is google.maps.GeocoderStatus.OK
          if not @getMap().isHidden()
            @updateMapWithAddressComponents(results)
        else
          @geocodeTimeout = setTimeout (=>
            @updateDeliveryLocAddressByLatLng lat, lng
            ), 1000

  mapMode: ->
    if @getMap().isHidden()
      @hideAllSavedLoc()
      @getMap().show()
      @getCenterMapButton().show()
      @getSpacerBetweenMapAndAddress().show()
      @getGasPriceMapDisplay().show()
      @getRequestGasButtonContainer().show()
      @getRequestAddressField().disable()
      @getRequestAddressField().setValue("Updating Location...")
      analytics?.page 'Map'

  recenterAtUserLoc: (showAlertIfUnavailable = false) ->
    if @geolocationAllowed?
      if not @geolocationAllowed
        if showAlertIfUnavailable
          navigator.notification.alert "To use the current location button, please allow geolocation for Purple in your phone's settings.", (->), "Current Location Unavailable"
      else
        @getMap().getMap().setCenter(
          new google.maps.LatLng @lat, @lng
        )

  addressInputMode: ->
    if not @getMap().isHidden()
      @addressInputSubMode = ''
      @hideAllSavedLoc()
      @getMap().hide()
      @getSpacerBetweenMapAndAddress().hide()
      @getGasPriceMapDisplay().hide()
      @getRequestGasButtonContainer().hide()
      @getAutocompleteList().show()
      @getRequestAddressField().enable()
      @getRequestAddressField().focus()
      @showSavedLoc()
      util.ctl('Menu').pushOntoBackButton =>
        @recenterAtUserLoc()
        @mapMode()
      ga_storage._trackEvent 'ui', 'Address Text Input Mode'
      analytics?.page 'Address Text Input Mode'

  editSavedLoc: ->
    @addressInputSubMode = ''
    @hideAllSavedLoc()
    @getAutocompleteList().show()
    @showSavedLoc()
    util.ctl('Menu').pushOntoBackButton =>
      @recenterAtUserLoc()
      @mapMode()

  showSavedLoc: ->
    if localStorage['purpleUserHomeLocationName']
      @getAccountHomeAddress().setValue(localStorage['purpleUserHomeLocationName'])
      @getHomeAddressContainer().show()
    else
      @getAddHomeAddressContainer().show()
    if localStorage['purpleUserWorkLocationName']
      @getAccountWorkAddress().setValue(localStorage['purpleUserWorkLocationName'])
      @getWorkAddressContainer().show()
    else
      @getAddWorkAddressContainer().show()

  showTitles: (location) ->
    if @addressInputSubMode is 'home'
      if localStorage['purpleUserHomeLocationName']
        @getRequestAddressField().setValue('Change Home Address...')
      else
        @getRequestAddressField().setValue('Add Home Address...')
    else if @addressInputSubMode is 'work'
      if localStorage['purpleUserWorkLocationName']
        @getRequestAddressField().setValue('Edit Work Address...')
      else
        @getRequestAddressField().setValue('Add Work Address...')

  removeAddress: ->
    @updateSavedLocations {
      home: if @addressInputSubMode is 'home'
        displayText: ''
        googlePlaceId: ''
      else
        displayText: localStorage['purpleUserHomeLocationName']
        googlePlaceId: localStorage['purpleUserHomePlaceId']
      work: if @addressInputSubMode is 'work'
        displayText: ''
        googlePlaceId: ''
      else
        displayText: localStorage['purpleUserWorkLocationName']
        googlePlaceId: localStorage['purpleUserWorkPlaceId']
      }, ->
        util.ctl('Main').editSavedLoc()
        util.ctl('Menu').popOffBackButtonWithoutAction()
        util.ctl('Menu').popOffBackButtonWithoutAction()

  showRemoveButtons: (location) ->
    if @addressInputSubMode is 'home' and localStorage['purpleUserHomeLocationName']
      @getRemoveHomeAddressContainer().show()
    if @addressInputSubMode is 'work' and localStorage['purpleUserWorkLocationName']
      @getRemoveWorkAddressContainer().show()

  hideAllSavedLoc: ->
    @getAddWorkAddressContainer().hide()
    @getAddHomeAddressContainer().hide()
    @getAutocompleteList().hide()
    @getHomeAddressContainer().hide()
    @getWorkAddressContainer().hide()
    @getRemoveHomeAddressContainer().hide()
    @getRemoveWorkAddressContainer().hide()
    @getCenterMapButton().hide()
    @getRequestAddressField().setValue('')

  editAddressInputMode: ->
    @hideAllSavedLoc()
    @getAutocompleteList().show()
    @showRemoveButtons()
    @showTitles()
    util.ctl('Menu').pushOntoBackButton =>
      @editSavedLoc()
      util.ctl('Menu').popOffBackButtonWithoutAction()

  generateSuggestions: ->
    @getRequestGasButton().setDisabled yes
    request = input: @getRequestAddressField().getValue()
    @placesAutocompleteService ?= new google.maps.places.AutocompleteService()
    @placesAutocompleteService.getPlacePredictions request, @populateAutocompleteList

  populateAutocompleteList: (predictions, status) ->
    if status is 'OK'
      suggestions = new Array()
      for p in predictions
        isAddress = p.terms[0].value is ""+parseInt(p.terms[0].value)
        locationName = if isAddress then p.terms[0].value + " " + p.terms[1]?.value else p.terms[0].value
        suggestions.push
          'locationName': locationName
          'locationVicinity': p.description.replace locationName+', ', ''
          'locationLat': '0'
          'locationLng': '0'
          'placeId': p.place_id
      util.ctl('Main').getAutocompleteList().getStore().setData suggestions

  updateDeliveryLocAddressByLocArray: (loc) ->
    @mapMode()
    @getRequestAddressField().setValue loc['locationName']
    util.ctl('Menu').clearBackButtonStack()
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
        @bypassUpdateDeliveryLocAddressByLatLng = true
        @getMap().getMap().setCenter latlng
        @updateMapWithAddressComponents([place])
        @getMap().getMap().setZoom 17
      # else
      #   console.log 'placesService error' + status
      
  handleAutoCompleteListTap: (loc) ->
    @loc = loc
    if @addressInputSubMode
      @updateAddress()
    @updateDeliveryLocAddressByLocArray loc

  changeHomeAddress: ->
    @addressInputSubMode = 'home'
    @editAddressInputMode()

  changeWorkAddress: ->
    @addressInputSubMode = 'work'
    @editAddressInputMode()

  updateAddress: ->
    if @addressInputSubMode is 'home'
      @updateSavedLocations {
        home: 
          displayText: @loc['locationName']
          googlePlaceId: @loc['placeId']
        work: if localStorage['purpleUserWorkLocationName']
          displayText: localStorage['purpleUserWorkLocationName']
          googlePlaceId: localStorage['purpleUserWorkPlaceId']
        else
          displayText: ''
          googlePlaceId: ''
        }, ->
          util.ctl('Main').getAccountHomeAddress().setValue(localStorage['purpleUserHomeLocationName'])
    if @addressInputSubMode is 'work'
      @updateSavedLocations {
        home: if localStorage['purpleUserHomeLocationName']
          displayText: localStorage['purpleUserHomeLocationName']
          googlePlaceId: localStorage['purpleUserHomePlaceId']
        else
          displayText: ''
          googlePlaceId: ''
        work: 
          displayText: @loc['locationName']
          googlePlaceId: @loc['placeId']
        }, ->
          util.ctl('Main').getAccountWorkAddress().setValue(localStorage['purpleUserWorkLocationName'])


  initAccountHomeAddress: (field) ->
    @getAccountHomeAddress().setValue(localStorage['purpleUserHomeLocationName'])
    field.element.on 'tap', @searchHome, this

  initAccountWorkAddress: (field) ->
    @getAccountWorkAddress().setValue(localStorage['purpleUserWorkLocationName'])
    field.element.on 'tap', @searchWork, this

  initAddWorkAddress: (field) ->
    field.element.on 'tap', @changeWorkAddress, this

  initAddHomeAddress: (field) ->
    field.element.on 'tap', @changeHomeAddress, this

  initRemoveHomeAddress: (field) ->
    field.element.on 'tap', @removeAddress, this

  initRemoveWorkAddress: (field) ->
    field.element.on 'tap', @removeAddress, this

  currentLocation: (locationName, placeId) ->
    {locationName: locationName, placeId: placeId}

  searchHome: ->
    @updateDeliveryLocAddressByLocArray @currentLocation(localStorage['purpleUserHomeLocationName'], localStorage['purpleUserHomePlaceId'])

  searchWork: ->
    @updateDeliveryLocAddressByLocArray @currentLocation(localStorage['purpleUserWorkLocationName'], localStorage['purpleUserWorkPlaceId'])
  
  updateSavedLocations: (savedLocations, callback) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/edit"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        saved_locations: savedLocations
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          localStorage['purpleUserHomeLocationName'] = response.saved_locations.home.displayText
          localStorage['purpleUserHomePlaceId'] = response.saved_locations.home.googlePlaceId
          localStorage['purpleUserWorkLocationName'] = response.saved_locations.work.displayText
          localStorage['purpleUserWorkPlaceId'] = response.saved_locations.work.googlePlaceId
          callback?()
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  showLogin: ->
    @getMainContainer().getItems().getAt(0).select 1, no, no

  isEmpty: (obj) ->
    for key of obj
      if obj.hasOwnProperty key
        return false
    true

  requestGasButtonPressed: ->
    deliveryLocName = @getRequestAddressField().getValue()
    ga_storage._trackEvent 'ui', 'Request Gas Button Pressed'
    analytics?.track 'Request Gas Button Pressed',
      address_street: deliveryLocName
      lat: @deliveryLocLat
      lng: @deliveryLocLng
      zip: @deliveryAddressZipCode
    if deliveryLocName is @getRequestAddressField().getInitialConfig().value
      return # just return, it hasn't loaded the location yet
    if not (util.ctl('Account').isUserLoggedIn() and util.ctl('Account').isCompleteAccount())
      # select the Login view
      @showLogin()
    else if true
      util.ctl('Subscriptions').showAd(
        (=> # pass-thru callback
          @initRequestGasForm deliveryLocName
        )
        (=> # active callback
          @getAccountTabContainer().setActiveItem(
            Ext.create 'Purple.view.Subscriptions'
          )
          util.ctl('Menu').pushOntoBackButton =>
            @backToAccount()
        )
      )
    else
      @initRequestGasForm deliveryLocName
      
  initRequestGasForm: (deliveryLocName) ->
    # send to request gas form
    # but first get availbility from disptach system
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      # use the gitignored availabilities.json file for testing
      # url: "availabilities.json"
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
          localStorage['purpleUserReferralCode'] = response.user.referral_code
          localStorage['purpleUserReferralGallons'] = "" + response.user.referral_gallons
          availabilities = response.availabilities
          # and, are there any time options available
          totalNumOfTimeOptions = availabilities.reduce (a, b) ->
            Object.keys(a.times).length + Object.keys(b.times).length
          if @isEmpty(availabilities[0].gallon_choices) and @isEmpty(availabilities[1].gallon_choices) or totalNumOfTimeOptions is 0
            navigator.notification.alert response["unavailable-reason"], (->), "Unavailable"
          else
            util.ctl('Menu').pushOntoBackButton =>
              @backToMapFromRequestForm()
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
            analytics?.page 'Order Form'
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
    util.ctl('Menu').pushOntoBackButton =>
      @backToRequestForm()
    vals = @getRequestForm().getValues()
    availabilities = @getRequestForm().config.availabilities
    gasType = util.ctl('Vehicles').getVehicleById(vals['vehicle']).gas_type
    for a in availabilities
      if a['octane'] is gasType
        availability = a
        break

    vals['gas_type'] = "" + availability.octane # should already be string though
    vals['gas_type_display'] = "Unleaded #{vals['gas_type']} Octane"
    gasPrice = availability.price_per_gallon
    serviceFee = availability.times[vals['time']]['service_fee']
    vals['gas_price'] = "" + util.centsToDollars(
      gasPrice
    )
    vals['gas_price_display'] = "$#{vals['gas_price']} x #{vals['gallons']}"
    vals['service_fee'] = "" + util.centsToDollars(
      serviceFee
    )

    freeGallonsAvailable = parseFloat localStorage['purpleUserReferralGallons']
    gallonsToSubtract = 0
    if freeGallonsAvailable is 0
      @getFreeGasField().hide()
    else
      # apply as much free gas as possible
      gallonsToSubtract = Math.min vals['gallons'], freeGallonsAvailable
      @getFreeGasField().setValue "- $#{vals['gas_price']} x #{gallonsToSubtract}"
    
    # it's called unaltered because it doesn't have a coupon code applied
    @unalteredTotalPrice = (
      parseFloat(gasPrice) * (parseFloat(vals['gallons']) - gallonsToSubtract) + parseFloat(serviceFee)
    )
    vals['total_price'] = "" + util.centsToDollars @unalteredTotalPrice
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
    else
      Ext.ComponentQuery.query('#specialInstructionsConfirmation')[0].setHtml(vals['special_instructions'])

    analytics?.page 'Review Order'
  
  promptForCode: ->
    Ext.Msg.prompt(
      'Enter Coupon Code',
      false,
      ((buttonId, text) =>
        if buttonId is 'ok'
          @applyCode text
        Ext.select('.x-msgbox .x-input-el').setStyle('text-transform', 'none')
        )
    )

  applyCode: (code) ->
    vals = @getRequestConfirmationForm().getValues()
    vehicleId = vals['vehicle_id']
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/code"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        vehicle_id: vehicleId
        code: code
        address_zip: @deliveryAddressZipCode
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        analytics?.track 'Tried Coupon Code',
          valid: response.success
          coupon_code: code.toUpperCase()
        if response.success
          @getDiscountField().setValue(
            "- $" + util.centsToDollars(Math.abs(response.value))
          )
          @getCouponCodeField().setValue code
          totalPrice = Math.max(
            @unalteredTotalPrice + response.value,
            0
          )
          @getTotalPriceField().setValue "" + util.centsToDollars(totalPrice)
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response

  confirmOrder: ->
    if not util.ctl('Account').hasDefaultPaymentMethod()
      # select the Account view
      @getMainContainer().getItems().getAt(0).select 2, no, no
      pmCtl = util.ctl('PaymentMethods')
      if not pmCtl.getPaymentMethods()?
        pmCtl.paymentMethodFieldTap yes
        
      pmCtl.showEditPaymentMethodForm 'new', yes
      util.ctl('Menu').pushOntoBackButton ->
        pmCtl.backToPreviousPage()
        util.ctl('Menu').selectOption 0
      
      pmCtl.getEditPaymentMethodForm().config.saveChangesCallback = ->
        pmCtl.backToPreviousPage()
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
            localStorage['specialInstructions'] = vals['special_instructions']
            util.ctl('Vehicles').specialInstructionsAutoFillPrompted = false
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
            util.ctl('Menu').clearBackButtonStack()
            navigator.notification.alert response.message, (->), (response.message_title ? "Success")
            # set up push notifications if they arent set up
            # NOTE: This will matter less and less, now that we set up push
            # notifications when a user creates their account. But it's nice to
            # keep this here for existing users that have never ordered and
            # don't logout and login (which would also cause a setup)
            @setUpPushNotifications true
          else
            navigator.notification.alert response.message, (->), (response.message_title ? "Error")
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

  # this is legacy code?
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
    @courierPingIntervalRef ?= setInterval (Ext.bind @courierPing, this), 10000

  killCourierPing: ->
    if @courierPingIntervalRef?
      clearInterval @courierPingIntervalRef
      @courierPingIntervalRef = null

  courierPing: ->
    @errorCount ?= 0
    @courierPingBusy ?= no
    if not @courierPingBusy
      @courierPingBusy = yes
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
          position_accuracy: @positionAccuracy
        headers:
          'Content-Type': 'application/json'
        timeout: 30000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          @courierPingBusy = no
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            if @disconnectedMessage?
              clearTimeout @disconnectedMessage
            Ext.get(document.getElementsByTagName('body')[0]).removeCls 'disconnected'
            @disconnectedMessage = setTimeout (->Ext.get(document.getElementsByTagName('body')[0]).addCls 'disconnected'), (2 * 60 * 1000)
          else
            navigator.notification.alert response.message, (->), (response.message_title ? "Error")
        failure: (response_obj) ->
          @errorCount++
          if @errorCount > 10
            @errorCount = 0
            navigator.notification.alert "Error #5. Unable to ping dispatch center. Please notify Purple support about this error.", (->), "Error"
          @courierPingBusy = no
          
