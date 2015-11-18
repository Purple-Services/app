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
      homeAutocomplete: '#homeAutocomplete'
      workAutocomplete: '#workAutocomplete'
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
        centerchange: 'adjustDeliveryLocByLatLng'
        maprender: 'initGeocoder'
      requestAddressField:
        generateSuggestions: 'generateSuggestions'
        addressInputMode: 'addressInputMode'
      workAutocomplete:
        updateWorkAddress: 'updateWorkAddress'
      homeAutocomplete:
        updateHomeAddress: 'updateHomeAddress'
      autocompleteList:
        updateDeliveryLocAddressByLocArray: 'updateDeliveryLocAddressByLocArray'
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

    @gpsIntervalRef = setInterval (Ext.bind @updateLatlng, this), 5000

    # Uncomment this for customer app, but courier doesn't need it
    ga_storage?._enableSSL() # doesn't seem to actually use SSL?
    ga_storage?._setAccount 'UA-61762011-1'
    ga_storage?._setDomain 'none'
    ga_storage?._trackEvent 'main', 'App Launch', "Platform: #{Ext.os.name}"

    navigator.splashscreen?.hide()

    if util.ctl('Account').hasPushNotificationsSetup()
      setTimeout (Ext.bind @setUpPushNotifications, this), 4000

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
      navigator.geolocation?.getCurrentPosition(
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
    # this is called on maprender, so let's make sure we have user loc centered
    @updateLatlng()
    if google? and google.maps? and @getMap()?
      @geocoder = new google.maps.Geocoder()
      @placesService = new google.maps.places.PlacesService @getMap().getMap()
      @mapInited = true
    else
      navigator.notification.alert "Internet connection problem. Please try closing the app and restarting it.", (->), "Connection Error"

  dragStart: ->
    @getRequestGasButton().setDisabled yes

  boundChanged: ->
    @getRequestGasButton().setDisabled yes

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
        # else
        #   console.log 'No results found.'

      # else
      #   console.log 'Geocoder failed due to: ' + status

  mapMode: ->
    if @getMap().isHidden()
      @hideAll()
      @getMap().show()
      @getCenterMapButton().show()
      @getSpacerBetweenMapAndAddress().show()
      @getGasPriceMapDisplay().show()
      @getRequestGasButtonContainer().show()
      @getRequestAddressField().disable()

  recenterAtUserLoc: ->
    @getMap().getMap().setCenter(
      new google.maps.LatLng @lat, @lng
    )

  addressInputMode: ->
    if not @getMap().isHidden()
      @hideAll()
      @getMap().hide()
      @getSpacerBetweenMapAndAddress().hide()
      @getGasPriceMapDisplay().hide()
      @getRequestGasButtonContainer().hide()
      @getAutocompleteList().show()
      @getRequestAddressField().enable()
      @getRequestAddressField().focus()
      @showHomeAndWork()
      util.ctl('Menu').pushOntoBackButton =>
        @recenterAtUserLoc()
        @mapMode()
      ga_storage._trackEvent 'ui', 'Address Text Input Mode'

  editSavedLoc: ->
    @hideAll()
    @getAutocompleteList().show()
    @showHomeAndWork()
    util.ctl('Menu').pushOntoBackButton =>
      @recenterAtUserLoc()
      @mapMode()

  showHomeAndWork: ->
    if localStorage['purpleUserHome']
      @getHomeAddressContainer().show()
    else
      @getAddHomeAddressContainer().show()
    if localStorage['purpleUserWork']
      @getWorkAddressContainer().show()
    else
      @getAddWorkAddressContainer().show()

  showTitles: (location) ->
    if location == 'home'
      if localStorage['purpleUserHome']
        @getRequestAddressField().setValue('Change Home Address...')
      else
        @getRequestAddressField().setValue('Add Home Address...')
    else
      if localStorage['purpleUserWork']
        @getRequestAddressField().setValue('Edit Work Address...')
      else
        @getRequestAddressField().setValue('Add Work Address...')

  removeHomeAddress: ->
    localStorage['purpleUserHome'] = ''
    @editSavedLoc()
    util.ctl('Menu').popOffBackButtonWithoutAction()
    util.ctl('Menu').popOffBackButtonWithoutAction()

  removeWorkAddress: ->
    localStorage['purpleUserWork'] = ''
    @editSavedLoc()
    util.ctl('Menu').popOffBackButtonWithoutAction()
    util.ctl('Menu').popOffBackButtonWithoutAction()

  showRemoveButtons: (location) ->
    if location == 'home' and localStorage['purpleUserHome']
      @getRemoveHomeAddressContainer().show()
    if location == 'work' and localStorage['purpleUserWork']
      @getRemoveWorkAddressContainer().show()

  hideAll: ->
    @getAddWorkAddressContainer().hide()
    @getAddHomeAddressContainer().hide()
    @getAutocompleteList().hide()
    @getHomeAutocomplete().hide()
    @getWorkAutocomplete().hide()
    @getHomeAddressContainer().hide()
    @getWorkAddressContainer().hide()
    @getRemoveHomeAddressContainer().hide()
    @getRemoveWorkAddressContainer().hide()
    @getCenterMapButton().hide()
    @getRequestAddressField().setValue('')

  homeAddressInputMode: ->
    @hideAll()
    @getHomeAutocomplete().show()
    @showRemoveButtons('home')
    @showTitles('home')
    util.ctl('Menu').pushOntoBackButton =>
      @editSavedLoc()
      util.ctl('Menu').popOffBackButtonWithoutAction()

  workAddressInputMode: ->
    @hideAll()
    @getWorkAutocomplete().show()
    @showRemoveButtons('work')
    @showTitles('work')
    util.ctl('Menu').pushOntoBackButton =>
      @editSavedLoc()
      util.ctl('Menu').popOffBackButtonWithoutAction()

  generateSuggestions: ->
    @getRequestGasButton().setDisabled yes
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
          @getHomeAutocomplete().getStore().setData suggestions
          @getWorkAutocomplete().getStore().setData suggestions

  updateDeliveryLocAddressByLocArray: (loc) ->
    @getRequestAddressField().setValue loc['locationName']
    @mapMode()
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
        @getMap().getMap().setCenter latlng
        @getMap().getMap().setZoom 17
      # else
      #   console.log 'placesService error' + status
  changeHomeAddress: ->
    @homeAddressInputMode()

  changeWorkAddress: ->
    @workAddressInputMode()

  updateHomeAddress: (loc) ->
    localStorage['purpleUserHome'] = loc['locationName']
    @getAccountHomeAddress().setValue(localStorage['purpleUserHome'])
    @updateDeliveryLocAddressByLocArray loc
    @homeLoc = loc

  updateWorkAddress: (loc) ->
    localStorage['purpleUserWork'] = loc['locationName']
    @getAccountWorkAddress().setValue(localStorage['purpleUserWork'])
    @updateDeliveryLocAddressByLocArray loc
    @workLoc = loc

  initAccountHomeAddress: (field) ->
    @getAccountHomeAddress().setValue(localStorage['purpleUserHome'])
    field.element.on 'tap', @searchHome, this

  initAccountWorkAddress: (field) ->
    @getAccountWorkAddress().setValue(localStorage['purpleUserWork'])
    field.element.on 'tap', @searchWork, this

  initAddWorkAddress: (field) ->
    field.element.on 'tap', @changeWorkAddress, this

  initAddHomeAddress: (field) ->
    field.element.on 'tap', @changeHomeAddress, this

  initRemoveHomeAddress: (field) ->
    field.element.on 'tap', @removeHomeAddress, this

  initRemoveWorkAddress: (field) ->
    field.element.on 'tap', @removeWorkAddress, this

  searchHome: ->
    @updateDeliveryLocAddressByLocArray @homeLoc

  searchWork: ->
    @updateDeliveryLocAddressByLocArray @workLoc

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
            localStorage['purpleUserReferralCode'] = response.user.referral_code
            localStorage['purpleUserReferralGallons'] = "" + response.user.referral_gallons
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
    gasPrice = availability.price_per_gallon
    serviceFee = availability.times[vals['time']]['service_fee']
    vals['gas_price'] = "" + util.centsToDollars(
      gasPrice
    )
    vals['gas_price_display'] = "$#{vals['gas_price']} x #{vals['gallons']}"
    vals['service_fee'] = "" + util.centsToDollars(
      serviceFee
    )

    freeGallonsAvailable = parseInt localStorage['purpleUserReferralGallons']
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
  promptForCode: ->
    Ext.Msg.prompt(
      'Enter Coupon Code',
      false,
      ((buttonId, text) =>
        if buttonId is 'ok'
          @applyCode text)
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
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
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
        pmCtl.accountPaymentMethodFieldTap yes
        
      pmCtl.showEditPaymentMethodForm 'new', yes
      util.ctl('Menu').pushOntoBackButton ->
        pmCtl.backToAccount()
        util.ctl('Menu').selectOption 0
      
      pmCtl.getEditPaymentMethodForm().config.savessCallback = ->
        util.ctl('Menu').popOffBackButtonWithoutAction()
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
            util.ctl('Menu').clearBackButtonStack()
            navigator.notification.alert response.message, (->), (response.message_title ? "Success")
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
            @errorCount++
            if @errorCount > 10
              @errorCount = 0
              navigator.notification.alert "Unable to ping dispatch center. Web service problem, please notify Chris.", (->), "Error"
        failure: (response_obj) ->
          @courierPingBusy = no
