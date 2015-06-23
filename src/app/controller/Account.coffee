Ext.define 'Purple.controller.Account'
  extend: 'Ext.app.Controller'
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      accountForm: 'accountform'
      vehicles: 'vehicles'
      orders: 'orders'

      # LoginForm elements
      loginForm: 'loginform'
      loginButtonContainer: '#loginButtonContainer'
      registerButtonContainer: '#registerButtonContainer'
      forgotPasswordButtonContainer: '#forgotPasswordButtonContainer'
      createAccountButtonContainer: '#createAccountButtonContainer'
      termsMessage: '#termsMessage'
      showRegisterButtonContainer: '#showRegisterButtonContainer'
      showLoginButtonContainer: '#showLoginButtonContainer'
      purpleLoginLogo: '#purpleLoginLogo'
      finalStepText: '#finalStepText'
      alternativeLoginOptionsText: '#alternativeLoginOptionsText'
      alternativeLoginOptions: '#alternativeLoginOptions'
      emailAddressField: '#emailAddressField'
      emailAddressFieldLabel: '#emailAddressFieldLabel'
      passwordField: '#passwordField'
      passwordFieldLabel: '#passwordFieldLabel'
      nameField: '#nameField'
      nameFieldLabel: '#nameFieldLabel'
      phoneNumberField: '#phoneNumberField'
      phoneNumberFieldLabel: '#phoneNumberFieldLabel'

      # AccountForm elements
      accountNameField: '#accountNameField'
      accountPhoneNumberField: '#accountPhoneNumberField'
      accountEmailField: '#accountEmailField'
      accountPaymentMethodField: '#accountPaymentMethodField'
      accountHorizontalRuleAbovePaymentMethod: '[ctype=accountHorizontalRuleAbovePaymentMethod]'
      
    control:
      loginForm:
        nativeLogin: 'nativeLogin'
        nativeRegister: 'nativeRegister'
        createAccount: 'createAccount' # for adding phone and name to account
        resetPassword: 'resetPassword'
        facebookLogin: 'facebookLogin'
        googleLogin: 'googleLogin'
        showRegisterButtonTap: 'showRegisterForm'
        showLoginButtonTap: 'showLoginForm'
        showForgotPasswordButtonTap: 'showForgotPasswordForm'
      accountForm:
        logoutButtonTap: 'logout'

  launch: ->
    @callParent arguments

  nativeRegister: ->
    vals = @getLoginForm().getValues()
    @registerUser vals['email_address'], vals['password']

  # only for users of type = 'native'
  # for other users (google / fb) should just use authorizeUser()
  # regardless of whether or not they already exist in our db
  #
  # so, platformId is always email address
  # and, authKey is always password
  registerUser: (platformId, authKey) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/register"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        platform_id: platformId
        auth_key: authKey
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        # this will be treated the same as authorizeUser
        # because they are automatically logged in after creating
        # their account
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @getLoginForm().reset()
          localStorage['purpleUserType'] = response.user.type
          localStorage['purpleUserId'] = response.user.id
          localStorage['purpleUserEmail'] = response.user.email
          localStorage['purpleUserIsCourier'] = response.user.is_courier
          localStorage['purpleUserReferralCode'] = response.user.referral_code
          localStorage['purpleUserReferralGallons'] = response.user.referral_gallons
          localStorage['purpleToken'] = response.token
          # they don't have any vehicles or orders yet.
          util.ctl('Vehicles').vehicles = []
          util.ctl('Vehicles').loadVehiclesList()
          util.ctl('Orders').orders = []
          util.ctl('Orders').loadOrdersList()
          util.ctl('PaymentMethods').paymentMethods = []
          util.ctl('PaymentMethods').loadPaymentMethodsList()
          @accountSetup()
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response
        console.log 'login error'  

  nativeLogin: ->
    vals = @getLoginForm().getValues()
    @authorizeUser 'native', vals['email_address'], vals['password']

  # handles native users as a login
  # handles fb and google users as a login or register
  # (depending on whether or not they exist in our db)
  authorizeUser: (type, platformId, authKey, emailOverride = null) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/login"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        type: type
        platform_id: platformId
        auth_key: authKey
        email_override: emailOverride
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @getLoginForm().reset()
          localStorage['purpleUserType'] = response.user.type
          localStorage['purpleUserId'] = response.user.id
          localStorage['purpleUserName'] = response.user.name
          localStorage['purpleUserPhoneNumber'] = response.user.phone_number
          localStorage['purpleUserEmail'] = response.user.email
          localStorage['purpleUserIsCourier'] = response.user.is_courier
          localStorage['purpleUserReferralCode'] = response.user.referral_code
          localStorage['purpleUserReferralGallons'] = response.user.referral_gallons
          localStorage['purpleUserHasPushNotificationsSetUp'] = response.user.has_push_notifications_set_up
          localStorage['purpleToken'] = response.token
          delete localStorage['purpleDefaultPaymentMethodId']
          for c, card of response.cards
            if card.default
              localStorage['purpleDefaultPaymentMethodId'] = card.id
              localStorage['purpleDefaultPaymentMethodDisplayText'] = """
                #{card.brand} *#{card.last4}
              """
          util.ctl('PaymentMethods').paymentMethods = response.cards
          util.ctl('PaymentMethods').loadPaymentMethodsList()
          util.ctl('PaymentMethods').refreshAccountPaymentMethodField()
          util.ctl('Vehicles').vehicles = response.vehicles
          util.ctl('Vehicles').loadVehiclesList()
          util.ctl('Orders').orders = response.orders
          util.ctl('Orders').loadOrdersList()
          if response.account_complete? and not response.account_complete
            @accountSetup()
          else
            util.ctl('Menu').adjustForAppLoginState()
            if @isCourier()
              # a courier account, go to Gas Tanks page
              util.ctl('Menu').selectOption 8
              # Courier's get their push notifications set up the first time
              # they log in as a courier (usually this requires a log out,
              # db change, then log back in). Customers, on the other hand,
              # get their push notifications set up the upon creation of their
              # first order.
              # We call it every time though because it still needs be initiated
              if not @hasPushNotificationsSetup()
                util.ctl('Main').setUpPushNotifications()
            else
              # a normal user, go to Request Gas page
              util.ctl('Menu').selectOption 0
              # initiate push notifications if they have them set up
              if @hasPushNotificationsSetup()
                util.ctl('Main').setUpPushNotifications()
            @showLoginForm() # to prepare for next logout, if it comes
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response
        console.log 'login error'

  facebookLogin: ->
    ga_storage._trackEvent 'ui', 'Facebook Login Pressed'
    facebookConnectPlugin.getLoginStatus(
      ((result) =>
        if result['status'] is 'connected'
          # they've done this before, just renew *our* 'purpleToken'
          @authorizeUser(
            'facebook',
            result['authResponse']['userID'],
            result['authResponse']['accessToken']
          )
        else
          # they haven't logged into our fb app yet (or they removed it)
          facebookConnectPlugin.login(
            ["email"],
            (Ext.bind @facebookLoginSuccess, this),
            (Ext.bind @facebookLoginFailure, this)
          )
      ),
      (-> console.log 'error', arguments)
    )
    
  facebookLoginSuccess: (result) ->
    @authorizeUser(
      'facebook',
      result['authResponse']['userID'],
      result['authResponse']['accessToken']
    )
    
  facebookLoginFailure: (error) ->
    console.log 'Facebook login error: ' + JSON.stringify(error)
    alert "Facebook login error. Please make sure your Facebook app is logged in correctly."

  googleLogin: ->
    ga_storage._trackEvent 'ui', 'Google Login Pressed'
    window.plugins.googleplus.login(
      {
        'iOSApiKey': '727391770434-at8c78sr3f227q53jkp73s9u7mfmarrs.apps.googleusercontent.com'
        # note: there is no API key needed for Android devices
      },
      (Ext.bind @googleLoginSuccess, this),
      (-> console.log 'error', arguments)
    )

  googleLoginSuccess: (result) ->
    console.log JSON.stringify(result)
    @authorizeUser(
      'google',
      result['userId'],
      result['oauthToken'],
      result['email'] # revelant to Android version only. iOS will get email scope server-side
    )

  accountSetup: ->
    @showAccountSetupForm()

  createAccount: ->
    # for adding phone and name to account that was just created in db
    name = @getNameField().getValue()
    phoneNumber = @getPhoneNumberField().getValue()
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/edit"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        user:
          name: name
          phone_number: phoneNumber
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @getLoginForm().reset()
          localStorage['purpleUserPhoneNumber'] = response.user.phone_number
          localStorage['purpleUserName'] = response.user.name
          util.ctl('Menu').adjustForAppLoginState()
          util.ctl('Menu').selectOption 0
          @showLoginForm() # to prepare for next logout, if it comes
          ga_storage._trackEvent 'main', 'Account Created'
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response
        console.log 'login error'

  showAccountSetupForm: ->
    @getLoginButtonContainer().hide()
    @getShowRegisterButtonContainer().hide()
    @getShowLoginButtonContainer().hide()
    @getRegisterButtonContainer().hide()
    @getEmailAddressField().hide()
    @getEmailAddressFieldLabel().hide()
    @getPasswordField().hide()
    @getPasswordFieldLabel().hide()
    @getAlternativeLoginOptions().hide()
    @getAlternativeLoginOptionsText().hide()
    @getPurpleLoginLogo().hide()
    @getFinalStepText().show()
    @getNameField().show()
    @getNameFieldLabel().show()
    @getPhoneNumberField().show()
    @getPhoneNumberFieldLabel().show()
    @getCreateAccountButtonContainer().show()
    @getTermsMessage().show()
    # populate with any info we might have (depending on user type)
    if localStorage['purpleUserName']? and localStorage['purpleUserName'] isnt ''
      @getNameField().setValue localStorage['purpleUserName']
    if localStorage['purpleUserPhoneNumber']? and localStorage['purpleUserPhoneNumber'] isnt ''
      @getPhoneNumberField().setValue localStorage['purpleUserPhoneNumber']
    
  showRegisterForm: ->
    @getLoginButtonContainer().hide()
    @getShowRegisterButtonContainer().hide()
    @getShowLoginButtonContainer().show()
    @getRegisterButtonContainer().show()

  showLoginForm: ->
    @getFinalStepText().hide()
    @getNameField().hide()
    @getNameFieldLabel().hide()
    @getPhoneNumberField().hide()
    @getPhoneNumberFieldLabel().hide()
    @getCreateAccountButtonContainer().hide()
    @getTermsMessage().hide()
    @getShowLoginButtonContainer().hide()
    @getRegisterButtonContainer().hide()
    @getForgotPasswordButtonContainer().hide()
    @getEmailAddressField().show()
    @getEmailAddressFieldLabel().show()
    @getAlternativeLoginOptions().show()
    @getAlternativeLoginOptionsText().show()
    @getPurpleLoginLogo().show()
    @getPasswordField().show()
    @getPasswordFieldLabel().show()
    @getLoginButtonContainer().show()
    @getShowRegisterButtonContainer().show()

  showForgotPasswordForm: ->
    @getPasswordField().hide()
    @getPasswordFieldLabel().hide()
    @getLoginButtonContainer().hide()
    @getShowRegisterButtonContainer().hide()
    @getShowLoginButtonContainer().show()
    @getForgotPasswordButtonContainer().show()

  logout: ->
    # send ajax to kill session?
    delete localStorage['purpleUserType']
    delete localStorage['purpleUserId']
    delete localStorage['purpleUserName']
    delete localStorage['purpleUserPhoneNumber']
    delete localStorage['purpleUserEmail']
    delete localStorage['purpleDefaultPaymentMethodId']
    delete localStorage['purpleDefaultPaymentMethodDisplayText']
    delete localStorage['purpleToken']
    delete localStorage['purpleUserIsCourier']
    delete localStorage['purpleCourierGallons87']
    delete localStorage['purpleCourierGallons91']
    delete localStorage['purpleUserHasPushNotificationsSetUp']
    delete localStorage['purpleUserReferralCode']
    delete localStorage['purpleUserReferralGallons']
    delete localStorage['purpleReferralReferredValue']
    delete localStorage['purpleReferralReferrerGallons']

    # clear out some lists from any old logins
    util.ctl('Vehicles').vehicles = []
    util.ctl('Vehicles').loadVehiclesList()
    util.ctl('Orders').orders = []
    util.ctl('Orders').loadOrdersList()
    util.ctl('PaymentMethods').paymentMethods = []
    util.ctl('PaymentMethods').loadPaymentMethodsList()

    util.ctl('Main').killCourierPing()
    
    util.ctl('Menu').adjustForAppLoginState()
    util.ctl('Menu').selectOption 1

    ga_storage._trackEvent 'main', 'Logged Out'
    
  isUserLoggedIn: ->
    localStorage['purpleUserId']? and localStorage['purpleUserId'] isnt '' and
    localStorage['purpleToken']? and localStorage['purpleToken'] isnt ''

  # of course, this is spoofable by changing localStorage manually
  isCompleteAccount: ->
    localStorage['purpleUserId']? and localStorage['purpleUserId'] isnt '' and
    localStorage['purpleToken']? and localStorage['purpleToken'] isnt '' and
    localStorage['purpleUserName']? and localStorage['purpleUserName'] isnt '' and
    localStorage['purpleUserPhoneNumber']? and localStorage['purpleUserPhoneNumber'] isnt '' and
    localStorage['purpleUserEmail']? and localStorage['purpleUserEmail'] isnt ''

  hasDefaultPaymentMethod: ->
    localStorage['purpleDefaultPaymentMethodId']? and localStorage['purpleDefaultPaymentMethodId'] isnt ''

  isCourier: ->
    # note that 'true' is in quotes intentionally
    localStorage['purpleUserIsCourier']? and localStorage['purpleUserIsCourier'] is 'true'

  hasPushNotificationsSetup: ->
    localStorage['purpleUserHasPushNotificationsSetUp']? and localStorage['purpleUserHasPushNotificationsSetUp'] is 'true'

  populateAccountForm: ->
    if localStorage['purpleUserName']? and localStorage['purpleUserName'] isnt ''
      @getAccountNameField()?.setValue localStorage['purpleUserName']
    if localStorage['purpleUserPhoneNumber']? and localStorage['purpleUserPhoneNumber'] isnt ''
      @getAccountPhoneNumberField()?.setValue localStorage['purpleUserPhoneNumber']
    if localStorage['purpleUserEmail']? and localStorage['purpleUserEmail'] isnt ''
      @getAccountEmailField()?.setValue localStorage['purpleUserEmail']
    if @isCourier()
      @getAccountPaymentMethodField()?.hide()
      @getAccountHorizontalRuleAbovePaymentMethod()?.hide()
    # TODO  (is this todo still relevant?)
    #@getAccountPaymentMethodField().setValue ''

  # only for users of type = 'native'
  resetPassword: ->
    vals = @getLoginForm().getValues()
    emailAddress = vals['email_address']
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/forgot-password"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        platform_id: emailAddress
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          @getLoginForm().reset()
          @showLoginForm()
          navigator.notification.alert response.message, (->), "Success!"
          ga_storage._trackEvent 'main', 'Password Reset Initiated'
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response
        console.log 'forgot password ajax error'
