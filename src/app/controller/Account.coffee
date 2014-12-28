Ext.define 'Purple.controller.Account'
  extend: 'Ext.app.Controller'
  requires: [
    'Purple.view.LoginForm'
  ]
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      accountForm: 'accountform'
      loginForm: 'loginform'
      loginButtonContainer: '#loginButtonContainer'
      registerButtonContainer: '#registerButtonContainer'
      showRegisterButtonContainer: '#showRegisterButtonContainer'
      showLoginButtonContainer: '#showLoginButtonContainer'
      alternativeLoginOptionsText: '#alternativeLoginOptionsText'
      alternativeLoginOptions: '#alternativeLoginOptions'
    control:
      loginForm:
        nativeLogin: 'nativeLogin'
        nativeRegister: 'nativeRegister'
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
          localStorage['purpleUserType'] = response.user_type
          localStorage['purpleUserId'] = response.user_id
          localStorage['purpleToken'] = response.token
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
          localStorage['purpleUserType'] = response.user_type
          localStorage['purpleUserId'] = response.user_id
          localStorage['purpleToken'] = response.token
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
    console.log 'logout'
    delete localStorage['purpleUserType']
    delete localStorage['purpleUserId']
    delete localStorage['purpleToken']
