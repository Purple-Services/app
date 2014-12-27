Ext.define 'Purple.controller.Account'
  extend: 'Ext.app.Controller'
  requires: [
    'Purple.view.LoginForm'
  ]
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      loginForm: 'loginform'
    control:
      loginForm:
        nativeLogin: 'nativeLogin'
        facebookLogin: 'facebookLogin'
        googleLogin: 'googleLogin'
        registerButtonTap: 'showRegisterForm'

  launch: ->
    @callParent arguments
    console.log 'Account controller launched'

  nativeLogin: ->
    vals = @getLoginForm().getValues()
    @authorizeUser 'native', vals['email_address'], vals['password']

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
    console.log 'dfd'
