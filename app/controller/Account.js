// Generated by CoffeeScript 1.3.3

Ext.define('Purple.controller.Account', {
  extend: 'Ext.app.Controller',
  config: {
    refs: {
      mainContainer: 'maincontainer',
      topToolbar: 'toptoolbar',
      accountForm: 'accountform',
      loginForm: 'loginform',
      loginButtonContainer: '#loginButtonContainer',
      registerButtonContainer: '#registerButtonContainer',
      createAccountButtonContainer: '#createAccountButtonContainer',
      showRegisterButtonContainer: '#showRegisterButtonContainer',
      showLoginButtonContainer: '#showLoginButtonContainer',
      purpleLoginLogo: '#purpleLoginLogo',
      finalStepText: '#finalStepText',
      alternativeLoginOptionsText: '#alternativeLoginOptionsText',
      alternativeLoginOptions: '#alternativeLoginOptions',
      emailAddressField: '#emailAddressField',
      emailAddressFieldLabel: '#emailAddressFieldLabel',
      passwordField: '#passwordField',
      passwordFieldLabel: '#passwordFieldLabel',
      nameField: '#nameField',
      nameFieldLabel: '#nameFieldLabel',
      phoneNumberField: '#phoneNumberField',
      phoneNumberFieldLabel: '#phoneNumberFieldLabel',
      accountNameField: '#accountNameField',
      accountPhoneNumberField: '#accountPhoneNumberField',
      accountEmailField: '#accountEmailField',
      accountPaymentMethodField: '#accountPaymentMethodField'
    },
    control: {
      loginForm: {
        nativeLogin: 'nativeLogin',
        nativeRegister: 'nativeRegister',
        createAccount: 'createAccount',
        facebookLogin: 'facebookLogin',
        googleLogin: 'googleLogin',
        showRegisterButtonTap: 'showRegisterForm',
        showLoginButtonTap: 'showLoginForm'
      },
      accountForm: {
        logoutButtonTap: 'logout'
      }
    }
  },
  launch: function() {
    return this.callParent(arguments);
  },
  nativeRegister: function() {
    var vals;
    vals = this.getLoginForm().getValues();
    return this.registerUser(vals['email_address'], vals['password']);
  },
  registerUser: function(platformId, authKey) {
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: "" + util.WEB_SERVICE_BASE_URL + "user/register",
      params: Ext.JSON.encode({
        platform_id: platformId,
        auth_key: authKey
      }),
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000,
      method: 'POST',
      scope: this,
      success: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        if (response.success) {
          this.getLoginForm().reset();
          localStorage['purpleUserType'] = response.user.type;
          localStorage['purpleUserId'] = response.user.id;
          localStorage['purpleUserEmail'] = response.user.email;
          localStorage['purpleToken'] = response.token;
          util.ctl('Vehicles').vehicles = [];
          return this.accountSetup();
        } else {
          return Ext.Msg.alert('Error', response.message, (function() {}));
        }
      },
      failure: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        console.log(response);
        return console.log('login error');
      }
    });
  },
  nativeLogin: function() {
    var vals;
    vals = this.getLoginForm().getValues();
    return this.authorizeUser('native', vals['email_address'], vals['password']);
  },
  authorizeUser: function(type, platformId, authKey) {
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: "" + util.WEB_SERVICE_BASE_URL + "user/login",
      params: Ext.JSON.encode({
        type: type,
        platform_id: platformId,
        auth_key: authKey
      }),
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000,
      method: 'POST',
      scope: this,
      success: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        if (response.success) {
          this.getLoginForm().reset();
          localStorage['purpleUserType'] = response.user.type;
          localStorage['purpleUserId'] = response.user.id;
          localStorage['purpleUserName'] = response.user.name;
          localStorage['purpleUserPhoneNumber'] = response.user.phone_number;
          localStorage['purpleUserEmail'] = response.user.email;
          localStorage['purpleToken'] = response.token;
          util.ctl('Vehicles').vehicles = response.vehicles;
          if ((response.account_complete != null) && !response.account_complete) {
            return this.accountSetup();
          } else {
            util.ctl('Menu').adjustForAppLoginState();
            return util.ctl('Menu').selectOption(0);
          }
        } else {
          return Ext.Msg.alert('Error', response.message, (function() {}));
        }
      },
      failure: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        console.log(response);
        return console.log('login error');
      }
    });
  },
  facebookLogin: function() {
    var _this = this;
    return facebookConnectPlugin.getLoginStatus((function(result) {
      if (result['status'] === 'connected') {
        return _this.authorizeUser('facebook', result['authResponse']['userID'], result['authResponse']['accessToken']);
      } else {
        return facebookConnectPlugin.login(["email"], Ext.bind(_this.facebookLoginSuccess, _this), Ext.bind(_this.facebookLoginFailure, _this));
      }
    }), (function() {
      return console.log('error', arguments);
    }));
  },
  facebookLoginSuccess: function(result) {
    console.log('facebookLoginSuccess');
    return this.authorizeUser('facebook', result['authResponse']['userID'], result['authResponse']['accessToken']);
  },
  facebookLoginFailure: function(errorStr) {
    return alert('Facebook login error: ', errorStr);
  },
  googleLogin: function() {
    return window.plugins.googleplus.login({
      'iOSApiKey': '727391770434-at8c78sr3f227q53jkp73s9u7mfmarrs.apps.googleusercontent.com'
    }, Ext.bind(this.googleLoginSuccess, this), (function() {
      return console.log('error', arguments);
    }));
  },
  googleLoginSuccess: function(result) {
    console.log(result);
    console.log('googleLoginSuccess');
    return this.authorizeUser('google', result['userId'], result['oauthToken']);
  },
  accountSetup: function() {
    return this.showAccountSetupForm();
  },
  createAccount: function() {
    var name, phoneNumber;
    name = this.getNameField().getValue();
    phoneNumber = this.getPhoneNumberField().getValue();
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: "" + util.WEB_SERVICE_BASE_URL + "user/edit",
      params: Ext.JSON.encode({
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken'],
        user: {
          name: name,
          phone_number: phoneNumber
        }
      }),
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000,
      method: 'POST',
      scope: this,
      success: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        if (response.success) {
          console.log('success ', response);
          this.getLoginForm().reset();
          util.ctl('Menu').adjustForAppLoginState();
          return util.ctl('Menu').selectOption(1);
        } else {
          return Ext.Msg.alert('Error', response.message, (function() {}));
        }
      },
      failure: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        console.log(response);
        return console.log('login error');
      }
    });
  },
  showAccountSetupForm: function() {
    this.getLoginButtonContainer().hide();
    this.getShowRegisterButtonContainer().hide();
    this.getShowLoginButtonContainer().hide();
    this.getRegisterButtonContainer().hide();
    this.getEmailAddressField().hide();
    this.getEmailAddressFieldLabel().hide();
    this.getPasswordField().hide();
    this.getPasswordFieldLabel().hide();
    this.getAlternativeLoginOptions().hide();
    this.getAlternativeLoginOptionsText().hide();
    this.getPurpleLoginLogo().hide();
    this.getFinalStepText().show();
    this.getNameField().show();
    this.getNameFieldLabel().show();
    this.getPhoneNumberField().show();
    this.getPhoneNumberFieldLabel().show();
    this.getCreateAccountButtonContainer().show();
    if ((localStorage['purpleUserName'] != null) && localStorage['purpleUserName'] !== '') {
      this.getNameField().setValue(localStorage['purpleUserName']);
    }
    if ((localStorage['purpleUserPhoneNumber'] != null) && localStorage['purpleUserPhoneNumber'] !== '') {
      return this.getPhoneNumberField().setValue(localStorage['purpleUserPhoneNumber']);
    }
  },
  showRegisterForm: function() {
    this.getLoginButtonContainer().hide();
    this.getShowRegisterButtonContainer().hide();
    this.getShowLoginButtonContainer().show();
    return this.getRegisterButtonContainer().show();
  },
  showLoginForm: function() {
    this.getShowLoginButtonContainer().hide();
    this.getRegisterButtonContainer().hide();
    this.getLoginButtonContainer().show();
    return this.getShowRegisterButtonContainer().show();
  },
  logout: function() {
    delete localStorage['purpleUserType'];
    delete localStorage['purpleUserId'];
    delete localStorage['purpleUserName'];
    delete localStorage['purpleUserPhoneNumber'];
    delete localStorage['purpleUserEmail'];
    delete localStorage['purpleToken'];
    util.ctl('Menu').adjustForAppLoginState();
    return util.ctl('Menu').selectOption(1);
  },
  isUserLoggedIn: function() {
    return (localStorage['purpleUserId'] != null) && localStorage['purpleUserId'] !== '';
  },
  populateAccountForm: function() {
    var _ref, _ref1, _ref2;
    if ((localStorage['purpleUserName'] != null) && localStorage['purpleUserName'] !== '') {
      if ((_ref = this.getAccountNameField()) != null) {
        _ref.setValue(localStorage['purpleUserName']);
      }
    }
    if ((localStorage['purpleUserPhoneNumber'] != null) && localStorage['purpleUserPhoneNumber'] !== '') {
      if ((_ref1 = this.getAccountPhoneNumberField()) != null) {
        _ref1.setValue(localStorage['purpleUserPhoneNumber']);
      }
    }
    if ((localStorage['purpleUserEmail'] != null) && localStorage['purpleUserEmail'] !== '') {
      return (_ref2 = this.getAccountEmailField()) != null ? _ref2.setValue(localStorage['purpleUserEmail']) : void 0;
    }
  }
});
