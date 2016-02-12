Ext.define 'Purple.controller.Account',
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
      googleLoginButton: '#googleLoginButton'

      # AccountForm elements
      accountNameField: '#accountNameField'
      accountPhoneNumberField: '#accountPhoneNumberField'
      accountEmailField: '#accountEmailField'
      accountPaymentMethodField: '#accountPaymentMethodField'
      accountHorizontalRuleAbovePaymentMethod: '[ctype=accountHorizontalRuleAbovePaymentMethod]'

      accountTabContainer: '#accountTabContainer'
      editAccountForm: 'editaccountform'
      
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
      accountNameField:
        initialize: 'initAccountNameField'
      accountPhoneNumberField:
        initialize: 'initAccountPhoneNumberField'
      accountEmailField:
        initialize: 'initAccountEmailField'
      editAccountForm:
        saveChanges: 'saveChanges'
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
          localStorage['purpleUserReferralGallons'] = "" + response.user.referral_gallons
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
          localStorage['purpleUserReferralGallons'] = "" + response.user.referral_gallons
          localStorage['purpleUserHasPushNotificationsSetUp'] = response.user.has_push_notifications_set_up
          localStorage['purpleToken'] = response.token
          localStorage['purpleUserHomeLocationName'] = response.saved_locations.home.displayText
          localStorage['purpleUserHomePlaceId'] = response.saved_locations.home.googlePlaceId
          localStorage['purpleUserWorkLocationName'] = response.saved_locations.work.displayText
          localStorage['purpleUserWorkPlaceId'] = response.saved_locations.work.googlePlaceId
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
          analytics?.identify localStorage['purpleUserId']
          if response.account_complete? and not response.account_complete
            @accountSetup()
          else
            util.ctl('Menu').adjustForAppLoginState()
            if @isCourier()
              # a courier account, go to Orders page
              # may want to go to Tanks page in future when we use that
              util.ctl('Menu').selectOption 3
              util.ctl('Main').setUpPushNotifications()
            else
              # a normal user, go to Request Gas page
              util.ctl('Menu').selectOption 0
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
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    ga_storage._trackEvent 'ui', 'Facebook Login Pressed'
    analytics?.track 'Facebook Login Pressed'
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
      (->
        Ext.Viewport.setMasked false
        console.log 'error', arguments)
    )
    
  facebookLoginSuccess: (result) ->
    @authorizeUser(
      'facebook',
      result['authResponse']['userID'],
      result['authResponse']['accessToken']
    )
    
  facebookLoginFailure: (error) ->
    Ext.Viewport.setMasked false
    alert "Facebook login error. Please make sure your Facebook app is logged in correctly."
    console.log 'Facebook login error: ' + JSON.stringify(error)

  googleLogin: ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    ga_storage._trackEvent 'ui', 'Google Login Pressed'
    analytics?.track 'Google Login Pressed'
    window.plugins.googleplus.login(
      (if Ext.os.name is "iOS"
        {
          'scopes': 'profile email'
        }
      else # Android
        {
          'scopes': 'profile email'
          'offline': true
        }),
      (Ext.bind @googleLoginSuccess, this),
      (->
        Ext.Viewport.setMasked false
        console.log 'error', arguments)
    )

  googleLoginSuccess: (result) ->
    if VERSION isnt "PROD"
      console.log JSON.stringify(result)
    @authorizeUser(
      'google',
      result['userId'],
      (if Ext.os.name is "iOS"
        result['accessToken']
      else # Android
        result['oauthToken']),
      result['email'] # revelant to old Android version only. iOS will get email scope server-side and also newer Android
    )

  accountSetup: ->
    @showAccountSetupForm()

  createAccount: ->
    # for adding phone and name to account that was just created in db
    name = @getNameField().getValue()
    phoneNumber = @getPhoneNumberField().getValue().replace(/[^\d]/gi, '')
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
          util.ctl('Main').setUpPushNotifications()
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
    if Ext.os.name is "iOS"
      @getGoogleLoginButton().hide()
      window.plugins?.googleplus?.isAvailable (available) =>
        if available then @getGoogleLoginButton().show()
    else
      @getGoogleLoginButton().show()

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

  populateAccountForm: ->
    if localStorage['purpleUserName']? and
    localStorage['purpleUserName'] isnt ''
      @getAccountNameField()?.setValue localStorage['purpleUserName']
    if localStorage['purpleUserPhoneNumber']? and
    localStorage['purpleUserPhoneNumber'] isnt ''
      phone = localStorage['purpleUserPhoneNumber']
      @getAccountPhoneNumberField()?.setValue switch
        when phone.length < 10 then phone
        when phone.length is 10 then "(#{phone.slice 0, 3}) #{phone.slice 3, 6} #{phone.slice 6}"
        else
          countryCodeLength = phone.length - 10
          "+#{phone.slice 0, countryCodeLength} (#{phone.slice countryCodeLength, (countryCodeLength + 3)}) #{phone.slice (countryCodeLength + 3), (countryCodeLength + 6)}-#{phone.slice (countryCodeLength + 6)}"
    if localStorage['purpleUserEmail']? and
    localStorage['purpleUserEmail'] isnt ''
      @getAccountEmailField()?.setValue localStorage['purpleUserEmail']
    if @isCourier()
      @getAccountPaymentMethodField()?.hide()
      @getAccountHorizontalRuleAbovePaymentMethod()?.hide()
    # TODO  (is this todo still relevant?)
    #@getAccountPaymentMethodField().setValue ''

  initAccountNameField: (field) ->
    field.element.on 'tap', Ext.bind @showEditAccountForm, this

  initAccountPhoneNumberField: (field) ->
    field.element.on 'tap', Ext.bind @showEditAccountForm, this

  initAccountEmailField: (field) ->
    field.element.on 'tap', Ext.bind @showEditAccountForm, this

  showEditAccountForm: ->
    @getAccountTabContainer().setActiveItem(
      Ext.create 'Purple.view.EditAccountForm'
    )
    @getEditAccountForm().setValues @getAccountForm().getValues()
    util.ctl('Menu').pushOntoBackButton =>
      # back to Account page
      @getAccountTabContainer().setActiveItem @getAccountForm()
      @getAccountTabContainer().remove(
        @getEditAccountForm(),
        yes
      )

  saveChanges: ->
    user = @getEditAccountForm().getValues()
    user.phone_number = user.phone_number.replace /[^\d]/gi, ''
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/edit"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        user: user
      headers:
        'Content-Type': 'application/json'
      timeout: 30000
      method: 'POST'
      scope: this
      success: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        if response.success
          localStorage['purpleUserEmail'] = response.user.email
          localStorage['purpleUserPhoneNumber'] = response.user.phone_number
          localStorage['purpleUserName'] = response.user.name
          # back to Account page
          @populateAccountForm()
          @getAccountTabContainer().setActiveItem @getAccountForm()
          @getAccountTabContainer().remove(
            @getEditAccountForm(),
            yes
          )
          util.ctl('Menu').popOffBackButtonWithoutAction()
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response
