Ext.define 'Purple.view.LoginForm',
  extend: 'Ext.form.Panel'
  xtype: 'loginform'
  requires: [
    'Ext.form.*'
    'Ext.field.*'
    'Ext.Button'
  ]
  config:
    layout:
      type: 'hbox'
      pack: 'center'
      align: 'center'
    height: '100%'
    cls: [
      'login-form'
      'login-form-bg'
      'slideable'
    ]
    scrollable:
      disabled: yes
      translatable:
        translationMethod: 'auto'
    submitOnAction: no
    listeners:
      initialize: ->
        util.ctl('Account').showLoginForm()
    items: [
      {
        xtype: 'container'
        id: 'showRegisterButtonContainer'
        flex: 0
        layout:
          type: 'hbox'
          pack: 'center'
          align: 'center'
        cls: 'links-container'
        style: """
          position: absolute;
          bottom: 15px;
          width: 100%;
          text-align: center;
        """
        items: [
          {
            xtype: 'spacer'
            flex: 1
          }
          {
            xtype: 'button'
            ui: 'plain'
            text: 'Create Account'
            handler: ->
              @up().up().fireEvent 'showRegisterButtonTap'
          }
          {
            xtype: 'spacer'
            flex: 1
          }
          {
            xtype: 'button'
            ui: 'plain'
            text: 'Forgot Password?'
            handler: ->
              @up().up().fireEvent 'showForgotPasswordButtonTap'
          }
          {
            xtype: 'spacer'
            flex: 1
          }
        ]
      }
      {
        xtype: 'container'
        id: 'showLoginButtonContainer'
        flex: 0
        layout:
          type: 'vbox'
          pack: 'start'
          align: 'center'
        cls: 'links-container'
        hidden: yes
        style: """
          position: absolute;
          bottom: 15px;
          width: 100%;
          text-align: center;
        """
        items: [
          {
            xtype: 'button'
            ui: 'plain'
            text: 'Log in with existing account'
            handler: ->
              @up().up().fireEvent 'showLoginButtonTap'
          }
        ]
      }
      {
        xtype: 'component'
        id: 'termsMessage'
        cls: 'terms-message'
        flex: 0
        hidden: yes
        style: """
          position: absolute;
          bottom: 15px;
          width: 100%;
          text-align: center;
        """
        html: """
          By creating an account,
          <br />you agree to the <a href="javascript:window.open('#{util.WEB_SERVICE_BASE_URL}/terms', '_blank', 'location=no')">Terms of Service</a>.
        """
      }
      {
        xtype: 'spacer'
        flex: 1
      }
      {
        xtype: 'container'
        flex: 0
        width: '75%'
        layout:
          type: 'vbox'
          pack: 'center'
          align: 'center'
        items: [
          {
            xtype: 'spacer'
            flex: 1
          }
          {
            xtype: 'component'
            id: 'purpleLoginLogo'
            flex: 0
            html: """
              <img src="resources/images/logo.png" class="login-logo" />
            """
          }
          {
            xtype: 'component'
            id: 'finalStepText'
            flex: 0
            padding: '30px 0 60px 0'
            hidden: yes
            html: """
              <span style="color: white; font-weight: 900; font-size: 22px;">
                Almost done...
              </span>
            """
          }
          {
            xtype: 'emailfield'
            id: 'emailAddressField'
            flex: 0
            name: 'email_address'
            clearIcon: no
            value: ''
          }
          {
            xtype: 'component'
            id: 'emailAddressFieldLabel'
            cls: 'special-label'
            flex: 0
            html: 'email'
          }
          {
            xtype: 'passwordfield'
            id: 'passwordField'
            flex: 0
            name: 'password'
            clearIcon: no
            value: ''
          }
          {
            xtype: 'component'
            id: 'passwordFieldLabel'
            cls: 'special-label'
            flex: 0
            html: 'password'
          }
          {
            xtype: 'textfield'
            id: 'nameField'
            flex: 0
            name: 'name'
            clearIcon: no
            value: ''
            hidden: yes
          }
          {
            xtype: 'component'
            id: 'nameFieldLabel'
            cls: 'special-label'
            flex: 0
            html: 'full name'
            hidden: yes
          }
          {
            xtype: 'phonefield'
            id: 'phoneNumberField'
            flex: 0
            name: 'phone_number'
            clearIcon: no
            component:
              type: 'tel'
            value: ''
            hidden: yes
          }
          {
            xtype: 'component'
            id: 'phoneNumberFieldLabel'
            cls: 'special-label'
            flex: 0
            html: 'phone number'
            hidden: yes
          }
          {
            xtype: 'container'
            id: 'loginButtonContainer'
            flex: 0
            height: 90
            layout:
              type: 'vbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Log in'
                flex: 0
                handler: ->
                  # 3 up()'s to get to loginform itself
                  @up().up().up().fireEvent 'nativeLogin'
              }
            ]
          }
          {
            xtype: 'container'
            id: 'registerButtonContainer'
            flex: 0
            height: 90
            hidden: yes
            layout:
              type: 'vbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Register'
                flex: 0
                handler: ->
                  # 3 up()'s to get to loginform itself
                  @up().up().up().fireEvent 'nativeRegister'
              }
            ]
          }
          {
            xtype: 'container'
            id: 'forgotPasswordButtonContainer'
            flex: 0
            height: 152
            hidden: yes
            layout:
              type: 'vbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Reset Password'
                flex: 0
                handler: ->
                  # 3 up()'s to get to loginform itself
                  @up().up().up().fireEvent 'resetPassword'
              }
            ]
          }
          {
            xtype: 'container'
            id: 'createAccountButtonContainer'
            flex: 0
            height: 110
            padding: '27 0 10 0'
            hidden: yes
            layout:
              type: 'vbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'button'
                ui: 'action'
                cls: 'button-pop'
                text: 'Create Account'
                flex: 0
                handler: ->
                  # 3 up()'s to get to loginform itself
                  @up().up().up().fireEvent 'createAccount'
              }
            ]
          }
          # {
          #   xtype: 'button'
          #   ui: 'plain'
          #   text: 'Terms of Service'
          #   handler: ->
          #     @up().up().fireEvent 'termsOfServiceLink'
          # }
          {
            xtype: 'component'
            id: 'alternativeLoginOptionsText'
            flex: 0
            html: 'or log in with'
            style: 'color: #69618E;'
          }
          {
            xtype: 'container'
            id: 'alternativeLoginOptions'
            flex: 0
            padding: '8 0 10 0'
            layout:
              type: 'hbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'spacer'
                flex: 1
              }
              {
                xtype: 'button'
                cls: 'icon-login-button'
                ui: 'plain'
                html: """
                  <img src="resources/images/facebook-logo.png" />
                """
                flex: 0
                handler: ->
                  # 3 up()'s to get to loginform itself
                  @up().up().up().fireEvent 'facebookLogin'
              }
              {
                xtype: 'spacer'
                flex: 1
              }
              {
                xtype: 'button'
                id: 'googleLoginButton'
                cls: 'icon-login-button'
                ui: 'plain'
                html: """
                  <img src="resources/images/google-logo.png" />
                """
                flex: 0
                hidden: yes
                handler: ->
                  # 3 up()'s to get to loginform itself
                  @up().up().up().fireEvent 'googleLogin'
              }
              {
                xtype: 'spacer'
                flex: 1
              }
            ]
          }
          {
            xtype: 'spacer'
            flex: 1
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]
