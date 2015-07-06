// Generated by CoffeeScript 1.3.3

Ext.define('Purple.view.LoginForm', {
  extend: 'Ext.form.Panel',
  xtype: 'loginform',
  requires: ['Ext.form.*', 'Ext.field.*', 'Ext.Button'],
  config: {
    layout: {
      type: 'hbox',
      pack: 'center',
      align: 'center'
    },
    height: '100%',
    cls: ['login-form', 'strong-accent-bg', 'slideable'],
    scrollable: {
      disabled: true,
      translatable: {
        translationMethod: 'auto'
      }
    },
    submitOnAction: false,
    listeners: {
      initialize: function() {
        return util.ctl('Account').showLoginForm();
      }
    },
    items: [
      {
        xtype: 'container',
        id: 'showRegisterButtonContainer',
        flex: 0,
        layout: {
          type: 'hbox',
          pack: 'center',
          align: 'center'
        },
        cls: 'links-container',
        style: "position: absolute;\nbottom: 15px;\nwidth: 100%;\ntext-align: center;",
        items: [
          {
            xtype: 'spacer',
            flex: 1
          }, {
            xtype: 'button',
            ui: 'plain',
            text: 'Create Account',
            handler: function() {
              return this.up().up().fireEvent('showRegisterButtonTap');
            }
          }, {
            xtype: 'spacer',
            flex: 1
          }, {
            xtype: 'button',
            ui: 'plain',
            text: 'Forgot Password?',
            handler: function() {
              return this.up().up().fireEvent('showForgotPasswordButtonTap');
            }
          }, {
            xtype: 'spacer',
            flex: 1
          }
        ]
      }, {
        xtype: 'container',
        id: 'showLoginButtonContainer',
        flex: 0,
        layout: {
          type: 'vbox',
          pack: 'start',
          align: 'center'
        },
        cls: 'links-container',
        hidden: true,
        style: "position: absolute;\nbottom: 15px;\nwidth: 100%;\ntext-align: center;",
        items: [
          {
            xtype: 'button',
            ui: 'plain',
            text: 'Log in with existing account',
            handler: function() {
              return this.up().up().fireEvent('showLoginButtonTap');
            }
          }
        ]
      }, {
        xtype: 'component',
        id: 'termsMessage',
        cls: 'terms-message',
        flex: 0,
        hidden: true,
        style: "position: absolute;\nbottom: 15px;\nwidth: 100%;\ntext-align: center;",
        html: "By creating an account,\n<br />you agree to the <a href=\"javascript:window.open('" + util.WEB_SERVICE_BASE_URL + "/terms', '_blank', 'location=no')\">Terms of Service</a>."
      }, {
        xtype: 'spacer',
        flex: 1
      }, {
        xtype: 'container',
        flex: 0,
        width: '75%',
        layout: {
          type: 'vbox',
          pack: 'center',
          align: 'center'
        },
        items: [
          {
            xtype: 'spacer',
            flex: 1
          }, {
            xtype: 'component',
            id: 'purpleLoginLogo',
            flex: 0,
            padding: '0 0 30px 0',
            html: "<img src=\"resources/images/logo-light.png\" class=\"login-logo\" />"
          }, {
            xtype: 'component',
            id: 'finalStepText',
            flex: 0,
            padding: '0 0 30px 0',
            hidden: true,
            html: "<span style=\"color: white; font-weight: 900; font-size: 22px;\">\n  Almost done...\n</span>"
          }, {
            xtype: 'emailfield',
            id: 'emailAddressField',
            flex: 0,
            name: 'email_address',
            clearIcon: false,
            value: ''
          }, {
            xtype: 'component',
            id: 'emailAddressFieldLabel',
            cls: 'special-label',
            flex: 0,
            html: 'email'
          }, {
            xtype: 'passwordfield',
            id: 'passwordField',
            flex: 0,
            name: 'password',
            clearIcon: false,
            value: ''
          }, {
            xtype: 'component',
            id: 'passwordFieldLabel',
            cls: 'special-label',
            flex: 0,
            html: 'password'
          }, {
            xtype: 'textfield',
            id: 'nameField',
            flex: 0,
            name: 'name',
            clearIcon: false,
            value: '',
            hidden: true
          }, {
            xtype: 'component',
            id: 'nameFieldLabel',
            cls: 'special-label',
            flex: 0,
            html: 'full name',
            hidden: true
          }, {
            xtype: 'textfield',
            id: 'phoneNumberField',
            flex: 0,
            name: 'phone_number',
            clearIcon: false,
            component: {
              type: 'tel'
            },
            value: '',
            hidden: true
          }, {
            xtype: 'component',
            id: 'phoneNumberFieldLabel',
            cls: 'special-label',
            flex: 0,
            html: 'phone number',
            hidden: true
          }, {
            xtype: 'container',
            id: 'loginButtonContainer',
            flex: 0,
            height: 110,
            padding: '27 0 10 0',
            layout: {
              type: 'vbox',
              pack: 'center',
              align: 'center'
            },
            items: [
              {
                xtype: 'button',
                ui: 'action',
                cls: 'button-pop',
                text: 'Log in',
                flex: 0,
                handler: function() {
                  return this.up().up().up().fireEvent('nativeLogin');
                }
              }
            ]
          }, {
            xtype: 'container',
            id: 'registerButtonContainer',
            flex: 0,
            height: 110,
            padding: '27 0 10 0',
            hidden: true,
            layout: {
              type: 'vbox',
              pack: 'center',
              align: 'center'
            },
            items: [
              {
                xtype: 'button',
                ui: 'action',
                cls: 'button-pop',
                text: 'Register',
                flex: 0,
                handler: function() {
                  return this.up().up().up().fireEvent('nativeRegister');
                }
              }
            ]
          }, {
            xtype: 'container',
            id: 'forgotPasswordButtonContainer',
            flex: 0,
            height: 110,
            padding: '27 0 10 0',
            hidden: true,
            layout: {
              type: 'vbox',
              pack: 'center',
              align: 'center'
            },
            items: [
              {
                xtype: 'button',
                ui: 'action',
                cls: 'button-pop',
                text: 'Reset Password',
                flex: 0,
                handler: function() {
                  return this.up().up().up().fireEvent('resetPassword');
                }
              }
            ]
          }, {
            xtype: 'container',
            id: 'createAccountButtonContainer',
            flex: 0,
            height: 110,
            padding: '27 0 10 0',
            hidden: true,
            layout: {
              type: 'vbox',
              pack: 'center',
              align: 'center'
            },
            items: [
              {
                xtype: 'button',
                ui: 'action',
                cls: 'button-pop',
                text: 'Create Account',
                flex: 0,
                handler: function() {
                  return this.up().up().up().fireEvent('createAccount');
                }
              }
            ]
          }, {
            xtype: 'component',
            id: 'alternativeLoginOptionsText',
            flex: 0,
            html: 'or log in with',
            style: 'color: #ffffff;'
          }, {
            xtype: 'container',
            id: 'alternativeLoginOptions',
            flex: 0,
            padding: '8 0 10 0',
            layout: {
              type: 'hbox',
              pack: 'center',
              align: 'center'
            },
            items: [
              {
                xtype: 'spacer',
                flex: 1
              }, {
                xtype: 'button',
                cls: 'icon-login-button',
                ui: 'plain',
                html: "<img src=\"resources/images/facebook-logo.png\" />",
                flex: 0,
                handler: function() {
                  return this.up().up().up().fireEvent('facebookLogin');
                }
              }, {
                xtype: 'spacer',
                flex: 1
              }, {
                xtype: 'button',
                id: 'googleLoginButton',
                cls: 'icon-login-button',
                ui: 'plain',
                html: "<img src=\"resources/images/google-logo.png\" />",
                flex: 0,
                hidden: true,
                handler: function() {
                  return this.up().up().up().fireEvent('googleLogin');
                }
              }, {
                xtype: 'spacer',
                flex: 1
              }
            ]
          }, {
            xtype: 'spacer',
            flex: 1
          }
        ]
      }, {
        xtype: 'spacer',
        flex: 1
      }
    ]
  }
});
