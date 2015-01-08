Ext.define 'Purple.controller.Account'
  extend: 'Ext.app.Controller'
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      accountForm: 'accountform'

      # LoginForm elements
      loginForm: 'loginform'
      loginButtonContainer: '#loginButtonContainer'
      registerButtonContainer: '#registerButtonContainer'
      createAccountButtonContainer: '#createAccountButtonContainer'
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
      
    control:
      loginForm:
        nativeLogin: 'nativeLogin'
        nativeRegister: 'nativeRegister'
        createAccount: 'createAccount' # for adding phone and name to account
        facebookLogin: 'facebookLogin'
        googleLogin: 'googleLogin'
        showRegisterButtonTap: 'showRegisterForm'
        showLoginButtonTap: 'showLoginForm'
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
          localStorage['purpleToken'] = response.token
          @accountSetup()
        else
          Ext.Msg.alert 'Error', response.message, (->)
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
  authorizeUser: (type, platformId, authKey) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}user/login"
      params: Ext.JSON.encode
        type: type
        platform_id: platformId
        auth_key: authKey
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
          localStorage['purpleToken'] = response.token
          if response.account_complete? and not response.account_complete
            @accountSetup()
          else
            util.ctl('Menu').adjustForAppLoginState()
            util.ctl('Menu').selectOption 0
        else
          Ext.Msg.alert 'Error', response.message, (->)
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        response = Ext.JSON.decode response_obj.responseText
        console.log response
        console.log 'login error'

  facebookLogin: ->
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
    console.log 'facebookLoginSuccess'
    @authorizeUser(
      'facebook',
      result['authResponse']['userID'],
      result['authResponse']['accessToken']
    )
    
  facebookLoginFailure: (errorStr) ->
    alert 'Facebook login error: ', errorStr

  googleLogin: ->
    window.plugins.googleplus.login(
      {
        'iOSApiKey': '727391770434-at8c78sr3f227q53jkp73s9u7mfmarrs.apps.googleusercontent.com'
        # note: there is no API key needed for Android devices
      },
      (Ext.bind @googleLoginSuccess, this),
      (-> console.log 'error', arguments)
    )

  googleLoginSuccess: (result) ->
    console.log result
    console.log 'googleLoginSuccess'
    @authorizeUser(
      'google',
      result['userId'],
      result['oauthToken']
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
          console.log 'success ', response
          @getLoginForm().reset()
          util.ctl('Menu').adjustForAppLoginState()
          util.ctl('Menu').selectOption 1
        else
          Ext.Msg.alert 'Error', response.message, (->)
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
    @getShowLoginButtonContainer().hide()
    @getRegisterButtonContainer().hide()
    @getLoginButtonContainer().show()
    @getShowRegisterButtonContainer().show()

  logout: ->
    # send ajax to kill session?
    delete localStorage['purpleUserType']
    delete localStorage['purpleUserId']
    delete localStorage['purpleUserName']
    delete localStorage['purpleUserPhoneNumber']
    delete localStorage['purpleUserEmail']
    delete localStorage['purpleToken']
    util.ctl('Menu').adjustForAppLoginState()
    util.ctl('Menu').selectOption 1
    
  isUserLoggedIn: ->
    localStorage['purpleUserId']? and localStorage['purpleUserId'] isnt ''

  populateAccountForm: ->
    if localStorage['purpleUserName']? and localStorage['purpleUserName'] isnt ''
      @getAccountNameField()?.setValue localStorage['purpleUserName']
    if localStorage['purpleUserPhoneNumber']? and localStorage['purpleUserPhoneNumber'] isnt ''
      @getAccountPhoneNumberField()?.setValue localStorage['purpleUserPhoneNumber']
    if localStorage['purpleUserEmail']? and localStorage['purpleUserEmail'] isnt ''
      @getAccountEmailField()?.setValue localStorage['purpleUserEmail']
    # TODO 
    #@getAccountPaymentMethodField().setValue ''
