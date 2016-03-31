Ext.define 'Purple.controller.Menu',
  extend: 'Ext.app.Controller'
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      logoButton: '[ctype=logoButton]'
      feedbackButton: '[ctype=feedbackButton]'
      helpButton: '[ctype=helpButton]'
      inviteButton: '[ctype=inviteButton]'
      menuButton: '[ctype=menuButton]'
      requestGasTabContainer: '#requestGasTabContainer'
      accountTab: '#accountTab'
      accountTabContainer: '#accountTabContainer'
      loginForm: 'loginform'
      mapForm: 'mapform'
      map: '#gmap'
      onDutyToggle: '[ctype=onDutyToggle]'
    control:
      logoButton:
        logoButtonTap: 'logoButtonTap'
      helpButton:
        helpButtonTap: 'helpButtonTap'
      feedbackButton:
        feedbackButtonTap: 'feedbackButtonTap'
      inviteButton:
        inviteButtonTap: 'inviteButtonTap'
      topToolbar:
        freeGasButtonTap: 'freeGasButtonTap'
        menuButtonTap: 'menuButtonTap'
      onDutyToggle:
        initialize: 'initOnDutyToggle'
        change: 'onDutyToggled'

  backButtonStack: []
  toggleFields: []
  bypassOnDutyToggledEvent: false

  launch: ->
    @callParent arguments

  open: ->
    @getMainContainer().openContainer()

  close: ->
    @getMainContainer().closeContainer()

  isClosed: ->
    @getMainContainer().isClosed()

  lockMenu: ->
    @getMainContainer().setSlideSelector false

  unlockMenu: ->
    @getMainContainer().setSlideSelector 'slideable'

  pushOntoBackButton: (fn) ->
    @backButtonStack.push fn
    @getMainContainer().addCls 'makeMenuButtonBeBackButton'
    @lockMenu()

  popOffBackButton: ->
    (@backButtonStack.pop())()
    if @backButtonStack.length is 0
      @getMainContainer().removeCls 'makeMenuButtonBeBackButton'
      @unlockMenu()

  popOffBackButtonWithoutAction: ->
    @backButtonStack.pop()
    if @backButtonStack.length is 0
      @getMainContainer().removeCls 'makeMenuButtonBeBackButton'
      @unlockMenu()

  clearBackButtonStack: ->
    @backButtonStack = []
    @getMainContainer().removeCls 'makeMenuButtonBeBackButton'
    @unlockMenu()

  logoButtonTap: ->
    @getMainContainer().getItems().getAt(0).select 0
    @close()

  menuButtonTap: ->
    if @backButtonStack.length isnt 0
      @popOffBackButton()
    else
      if @isClosed()
        @open()
      else
        @close()

  freeGasButtonTap: ->
    if not (util.ctl('Account').isUserLoggedIn() and util.ctl('Account').isCompleteAccount())
      # select the Login view
      @getMainContainer().getItems().getAt(0).select 1, no, no
      @unlockMenu()
    else if @getCurrentIndex() is 7
      # already on Free Gas page
      @selectOption (@indexBeforeFreeGas ? 2)
      @popOffBackButtonWithoutAction()
    else
      @indexBeforeFreeGas = @getCurrentIndex()
      @pushOntoBackButton => @selectOption @indexBeforeFreeGas
      @selectOption 7

  helpButtonTap: ->
    @selectOption 5
    @close()

  feedbackButtonTap: ->
    @selectOption 6
    @close()

  getCurrentIndex: ->
    @getMainContainer().getActiveItem().data.index

  selectOption: (index) ->
    @getMainContainer().getItems().getAt(0).select index, no, no

  changeTitle: (index, title) ->
    @getMainContainer().getAt(0).getAt(2).getAt(index).setData
      title: title

  showTitles: (indicies) ->
    for i in indicies
      @getMainContainer().getAt(0).getAt(2).getAt(i).show()

  hideTitles: (indicies) ->
    for i in indicies
      @getMainContainer().getAt(0).getAt(2).getAt(i).hide()

  initOnDutyToggle: (field) ->
    @toggleFields.push field
    @updateOnDutyToggle()

  manuallySetToggleValue: (value) ->
    @bypassOnDutyToggledEvent = true
    for field in @toggleFields
      field.setValue value
    @bypassOnDutyToggledEvent = false

  # Be advised this is being called for every toolbar instance's toggle element that gets inited on app launch
  updateOnDutyToggle: ->
    if localStorage['courierOnDuty'] is 'yes'
      util.ctl('Main').initCourierPing()
      @manuallySetToggleValue true
    else
      util.ctl('Main').killCourierPing()
      @manuallySetToggleValue false

  onDutyToggled: (field, newValue, oldValue) ->
    if not @bypassOnDutyToggledEvent
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      if newValue is 0
        @callCourierPing no
      else
        @callCourierPing yes

  callCourierPing: (setOnDuty) ->
    util.ctl('Main').courierPing(setOnDuty, (=> Ext.Viewport.setMasked false),
      (=>
        @updateOnDutyToggle()
        Ext.Viewport.setMasked false
      )
    )

  adjustForAppLoginState: ->
    if util.ctl('Account').isUserLoggedIn()
      @hideTitles [1]
      if util.ctl('Account').isCourier()
        @hideTitles [0, 4, 7, 8]
        @showTitles [2, 3]
        localStorage['purpleCourierGallons87'] ?= 0
        localStorage['purpleCourierGallons91'] ?= 0
        Ext.get(document.getElementsByTagName('body')[0]).addCls 'courier-app'
        Ext.get(document.getElementsByTagName('body')[0]).removeCls 'user-app'
        if localStorage['courierOnDuty'] is 'yes'
          util.ctl('Main').initCourierPing()
      else
        @hideTitles [8]
        @showTitles [2, 3, 4, 7]
        Ext.get(document.getElementsByTagName('body')[0]).removeCls 'courier-app'
        Ext.get(document.getElementsByTagName('body')[0]).addCls 'user-app'
      util.ctl('Account').populateAccountForm()
    else
      @hideTitles [2, 3, 4, 7, 8]
      @showTitles [1]
