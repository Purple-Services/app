Ext.define('Purple.controller.Account', {
  extend: 'Ext.app.Controller',
  config: {
    refs: {
      mainContainer: 'maincontainer',
      topToolbar: 'toptoolbar',
      accountForm: 'accountform',
      vehicles: 'vehicles',
      orders: 'orders',
      loginForm: 'loginform',
      loginButtonContainer: '#loginButtonContainer',
      registerButtonContainer: '#registerButtonContainer',
      forgotPasswordButtonContainer: '#forgotPasswordButtonContainer',
      createAccountButtonContainer: '#createAccountButtonContainer',
      termsMessage: '#termsMessage',
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
      googleLoginButton: '#googleLoginButton',
      accountNameField: '#accountNameField',
      accountPhoneNumberField: '#accountPhoneNumberField',
      accountEmailField: '#accountEmailField',
      accountPaymentMethodField: '#accountPaymentMethodField',
      accountHorizontalRuleAbovePaymentMethod: '[ctype=accountHorizontalRuleAbovePaymentMethod]',
      accountTabContainer: '#accountTabContainer',
      editAccountForm: 'editaccountform'
    },
    control: {
      loginForm: {
        nativeLogin: 'nativeLogin',
        nativeRegister: 'nativeRegister',
        createAccount: 'createAccount',
        resetPassword: 'resetPassword',
        facebookLogin: 'facebookLogin',
        googleLogin: 'googleLogin',
        showRegisterButtonTap: 'showRegisterForm',
        showLoginButtonTap: 'showLoginForm',
        showForgotPasswordButtonTap: 'showForgotPasswordForm'
      },
      accountNameField: {
        initialize: 'initAccountNameField'
      },
      accountPhoneNumberField: {
        initialize: 'initAccountPhoneNumberField'
      },
      accountEmailField: {
        initialize: 'initAccountEmailField'
      },
      editAccountForm: {
        saveChanges: 'saveChanges'
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
      url: util.WEB_SERVICE_BASE_URL + "user/register",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
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
          localStorage['purpleUserIsCourier'] = response.user.is_courier;
          localStorage['purpleUserReferralCode'] = response.user.referral_code;
          localStorage['purpleUserReferralGallons'] = "" + response.user.referral_gallons;
          localStorage['purpleToken'] = response.token;
          util.ctl('Vehicles').vehicles = [];
          util.ctl('Vehicles').loadVehiclesList();
          util.ctl('Orders').orders = [];
          util.ctl('Orders').loadOrdersList();
          util.ctl('PaymentMethods').paymentMethods = [];
          util.ctl('PaymentMethods').loadPaymentMethodsList();
          return this.accountSetup();
        } else {
          return navigator.notification.alert(response.message, (function() {}), "Error");
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
  authorizeUser: function(type, platformId, authKey, emailOverride) {
    if (emailOverride == null) {
      emailOverride = null;
    }
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: util.WEB_SERVICE_BASE_URL + "user/login",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        type: type,
        platform_id: platformId,
        auth_key: authKey,
        email_override: emailOverride
      }),
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000,
      method: 'POST',
      scope: this,
      success: function(response_obj) {
        var c, card, ref, response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        if (response.success) {
          this.getLoginForm().reset();
          localStorage['purpleUserType'] = response.user.type;
          localStorage['purpleUserId'] = response.user.id;
          localStorage['purpleUserName'] = response.user.name;
          localStorage['purpleUserPhoneNumber'] = response.user.phone_number;
          localStorage['purpleUserEmail'] = response.user.email;
          localStorage['purpleUserIsCourier'] = response.user.is_courier;
          localStorage['purpleUserReferralCode'] = response.user.referral_code;
          localStorage['purpleUserReferralGallons'] = "" + response.user.referral_gallons;
          localStorage['purpleUserHasPushNotificationsSetUp'] = response.user.has_push_notifications_set_up;
          localStorage['purpleToken'] = response.token;
          delete localStorage['purpleDefaultPaymentMethodId'];
          ref = response.cards;
          for (c in ref) {
            card = ref[c];
            if (card["default"]) {
              localStorage['purpleDefaultPaymentMethodId'] = card.id;
              localStorage['purpleDefaultPaymentMethodDisplayText'] = card.brand + " *" + card.last4;
            }
          }
          util.ctl('PaymentMethods').paymentMethods = response.cards;
          util.ctl('PaymentMethods').loadPaymentMethodsList();
          util.ctl('PaymentMethods').refreshAccountPaymentMethodField();
          util.ctl('Vehicles').vehicles = response.vehicles;
          util.ctl('Vehicles').loadVehiclesList();
          util.ctl('Orders').orders = response.orders;
          util.ctl('Orders').loadOrdersList();
          if ((response.account_complete != null) && !response.account_complete) {
            return this.accountSetup();
          } else {
            util.ctl('Menu').adjustForAppLoginState();
            if (this.isCourier()) {
              util.ctl('Menu').selectOption(3);
              if (!this.hasPushNotificationsSetup()) {
                util.ctl('Main').setUpPushNotifications();
              }
            } else {
              util.ctl('Menu').selectOption(0);
              if (this.hasPushNotificationsSetup()) {
                util.ctl('Main').setUpPushNotifications();
              }
            }
            return this.showLoginForm();
          }
        } else {
          return navigator.notification.alert(response.message, (function() {}), "Error");
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
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    ga_storage._trackEvent('ui', 'Facebook Login Pressed');
    return facebookConnectPlugin.getLoginStatus(((function(_this) {
      return function(result) {
        if (result['status'] === 'connected') {
          return _this.authorizeUser('facebook', result['authResponse']['userID'], result['authResponse']['accessToken']);
        } else {
          return facebookConnectPlugin.login(["email"], Ext.bind(_this.facebookLoginSuccess, _this), Ext.bind(_this.facebookLoginFailure, _this));
        }
      };
    })(this)), (function() {
      Ext.Viewport.setMasked(false);
      return console.log('error', arguments);
    }));
  },
  facebookLoginSuccess: function(result) {
    return this.authorizeUser('facebook', result['authResponse']['userID'], result['authResponse']['accessToken']);
  },
  facebookLoginFailure: function(error) {
    Ext.Viewport.setMasked(false);
    alert("Facebook login error. Please make sure your Facebook app is logged in correctly.");
    return console.log('Facebook login error: ' + JSON.stringify(error));
  },
  googleLogin: function() {
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    ga_storage._trackEvent('ui', 'Google Login Pressed');
    return window.plugins.googleplus.login({
      'scopes': 'profile email'
    }, Ext.bind(this.googleLoginSuccess, this), (function() {
      Ext.Viewport.setMasked(false);
      return console.log('error', arguments);
    }));
  },
  googleLoginSuccess: function(result) {
    console.log(JSON.stringify(result));
    return this.authorizeUser('google', result['userId'], result['accessToken'], result['email']);
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
      url: util.WEB_SERVICE_BASE_URL + "user/edit",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
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
          this.getLoginForm().reset();
          localStorage['purpleUserPhoneNumber'] = response.user.phone_number;
          localStorage['purpleUserName'] = response.user.name;
          util.ctl('Menu').adjustForAppLoginState();
          util.ctl('Menu').selectOption(0);
          this.showLoginForm();
          return ga_storage._trackEvent('main', 'Account Created');
        } else {
          return navigator.notification.alert(response.message, (function() {}), "Error");
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
    this.getTermsMessage().show();
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
    var ref, ref1;
    this.getFinalStepText().hide();
    this.getNameField().hide();
    this.getNameFieldLabel().hide();
    this.getPhoneNumberField().hide();
    this.getPhoneNumberFieldLabel().hide();
    this.getCreateAccountButtonContainer().hide();
    this.getTermsMessage().hide();
    this.getShowLoginButtonContainer().hide();
    this.getRegisterButtonContainer().hide();
    this.getForgotPasswordButtonContainer().hide();
    this.getEmailAddressField().show();
    this.getEmailAddressFieldLabel().show();
    this.getAlternativeLoginOptions().show();
    this.getAlternativeLoginOptionsText().show();
    this.getPurpleLoginLogo().show();
    this.getPasswordField().show();
    this.getPasswordFieldLabel().show();
    this.getLoginButtonContainer().show();
    this.getShowRegisterButtonContainer().show();
    if (Ext.os.name === "iOS") {
      this.getGoogleLoginButton().hide();
      return (ref = window.plugins) != null ? (ref1 = ref.googleplus) != null ? ref1.isAvailable((function(_this) {
        return function(available) {
          if (available) {
            return _this.getGoogleLoginButton().show();
          }
        };
      })(this)) : void 0 : void 0;
    } else {
      return this.getGoogleLoginButton().show();
    }
  },
  showForgotPasswordForm: function() {
    this.getPasswordField().hide();
    this.getPasswordFieldLabel().hide();
    this.getLoginButtonContainer().hide();
    this.getShowRegisterButtonContainer().hide();
    this.getShowLoginButtonContainer().show();
    return this.getForgotPasswordButtonContainer().show();
  },
  logout: function() {
    delete localStorage['purpleUserType'];
    delete localStorage['purpleUserId'];
    delete localStorage['purpleUserName'];
    delete localStorage['purpleUserPhoneNumber'];
    delete localStorage['purpleUserEmail'];
    delete localStorage['purpleDefaultPaymentMethodId'];
    delete localStorage['purpleDefaultPaymentMethodDisplayText'];
    delete localStorage['purpleToken'];
    delete localStorage['purpleUserIsCourier'];
    delete localStorage['purpleCourierGallons87'];
    delete localStorage['purpleCourierGallons91'];
    delete localStorage['purpleUserHasPushNotificationsSetUp'];
    delete localStorage['purpleUserReferralCode'];
    delete localStorage['purpleUserReferralGallons'];
    delete localStorage['purpleReferralReferredValue'];
    delete localStorage['purpleReferralReferrerGallons'];
    util.ctl('Vehicles').vehicles = [];
    util.ctl('Vehicles').loadVehiclesList();
    util.ctl('Orders').orders = [];
    util.ctl('Orders').loadOrdersList();
    util.ctl('PaymentMethods').paymentMethods = [];
    util.ctl('PaymentMethods').loadPaymentMethodsList();
    util.ctl('Main').killCourierPing();
    util.ctl('Menu').adjustForAppLoginState();
    util.ctl('Menu').selectOption(1);
    return ga_storage._trackEvent('main', 'Logged Out');
  },
  isUserLoggedIn: function() {
    return (localStorage['purpleUserId'] != null) && localStorage['purpleUserId'] !== '' && (localStorage['purpleToken'] != null) && localStorage['purpleToken'] !== '';
  },
  isCompleteAccount: function() {
    return (localStorage['purpleUserId'] != null) && localStorage['purpleUserId'] !== '' && (localStorage['purpleToken'] != null) && localStorage['purpleToken'] !== '' && (localStorage['purpleUserName'] != null) && localStorage['purpleUserName'] !== '' && (localStorage['purpleUserPhoneNumber'] != null) && localStorage['purpleUserPhoneNumber'] !== '' && (localStorage['purpleUserEmail'] != null) && localStorage['purpleUserEmail'] !== '';
  },
  hasDefaultPaymentMethod: function() {
    return (localStorage['purpleDefaultPaymentMethodId'] != null) && localStorage['purpleDefaultPaymentMethodId'] !== '';
  },
  isCourier: function() {
    return (localStorage['purpleUserIsCourier'] != null) && localStorage['purpleUserIsCourier'] === 'true';
  },
  hasPushNotificationsSetup: function() {
    return (localStorage['purpleUserHasPushNotificationsSetUp'] != null) && localStorage['purpleUserHasPushNotificationsSetUp'] === 'true';
  },
  resetPassword: function() {
    var emailAddress, vals;
    vals = this.getLoginForm().getValues();
    emailAddress = vals['email_address'];
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: util.WEB_SERVICE_BASE_URL + "user/forgot-password",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        platform_id: emailAddress
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
          this.showLoginForm();
          navigator.notification.alert(response.message, (function() {}), "Success!");
          return ga_storage._trackEvent('main', 'Password Reset Initiated');
        } else {
          return navigator.notification.alert(response.message, (function() {}), "Error");
        }
      },
      failure: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        console.log(response);
        return console.log('forgot password ajax error');
      }
    });
  },
  populateAccountForm: function() {
    var ref, ref1, ref2, ref3, ref4;
    if ((localStorage['purpleUserName'] != null) && localStorage['purpleUserName'] !== '') {
      if ((ref = this.getAccountNameField()) != null) {
        ref.setValue(localStorage['purpleUserName']);
      }
    }
    if ((localStorage['purpleUserPhoneNumber'] != null) && localStorage['purpleUserPhoneNumber'] !== '') {
      if ((ref1 = this.getAccountPhoneNumberField()) != null) {
        ref1.setValue(localStorage['purpleUserPhoneNumber']);
      }
    }
    if ((localStorage['purpleUserEmail'] != null) && localStorage['purpleUserEmail'] !== '') {
      if ((ref2 = this.getAccountEmailField()) != null) {
        ref2.setValue(localStorage['purpleUserEmail']);
      }
    }
    if (this.isCourier()) {
      if ((ref3 = this.getAccountPaymentMethodField()) != null) {
        ref3.hide();
      }
      return (ref4 = this.getAccountHorizontalRuleAbovePaymentMethod()) != null ? ref4.hide() : void 0;
    }
  },
  initAccountNameField: function(field) {
    return field.element.on('tap', Ext.bind(this.showEditAccountForm, this));
  },
  initAccountPhoneNumberField: function(field) {
    return field.element.on('tap', Ext.bind(this.showEditAccountForm, this));
  },
  initAccountEmailField: function(field) {
    return field.element.on('tap', Ext.bind(this.showEditAccountForm, this));
  },
  showEditAccountForm: function() {
    this.getAccountTabContainer().setActiveItem(Ext.create('Purple.view.EditAccountForm'));
    this.getEditAccountForm().setValues(this.getAccountForm().getValues());
    return util.ctl('Menu').pushOntoBackButton((function(_this) {
      return function() {
        _this.getAccountTabContainer().setActiveItem(_this.getAccountForm());
        return _this.getAccountTabContainer().remove(_this.getEditAccountForm(), true);
      };
    })(this));
  },
  saveChanges: function() {
    Ext.Viewport.setMasked({
      xtype: 'loadmask',
      message: ''
    });
    return Ext.Ajax.request({
      url: util.WEB_SERVICE_BASE_URL + "user/edit",
      params: Ext.JSON.encode({
        version: util.VERSION_NUMBER,
        user_id: localStorage['purpleUserId'],
        token: localStorage['purpleToken'],
        user: this.getEditAccountForm().getValues()
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
          localStorage['purpleUserEmail'] = response.user.email;
          localStorage['purpleUserPhoneNumber'] = response.user.phone_number;
          localStorage['purpleUserName'] = response.user.name;
          this.populateAccountForm();
          this.getAccountTabContainer().setActiveItem(this.getAccountForm());
          this.getAccountTabContainer().remove(this.getEditAccountForm(), true);
          return util.ctl('Menu').popOffBackButtonWithoutAction();
        } else {
          return navigator.notification.alert(response.message, (function() {}), "Error");
        }
      },
      failure: function(response_obj) {
        var response;
        Ext.Viewport.setMasked(false);
        response = Ext.JSON.decode(response_obj.responseText);
        return console.log(response);
      }
    });
  }
});
