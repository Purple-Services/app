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
    if util.ctl('Account').isCourier()
      @getMainContainer().getItems().getAt(0).select 3
      @close()
    else
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
    if localStorage['courierOnDuty'] is 'yes'
      @manuallySetToggleValue true

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
      # this is commented out because we decided we want to still get pings
      # from couriers who are off-duty yet connected: e.g., fleet couriers
      # util.ctl('Main').killCourierPing()
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
    bodyTag = Ext.get(document.getElementsByTagName('body')[0])
    bodyTag.removeCls 'courier-app'
    bodyTag.removeCls 'managed-account'
    if util.ctl('Account').isUserLoggedIn()
      @hideTitles [1] # Login page
      if util.ctl('Account').isCourier()
        bodyTag.addCls 'courier-app'
        @hideTitles [0, 4, 7, 8]
        @showTitles [2, 3, 9, 10, 11]
        localStorage['purpleCourierGallons87'] ?= 0
        localStorage['purpleCourierGallons91'] ?= 0
        util.ctl('Main').initCourierPing()
        localStorage['courierOnDuty'] ?= 'no'
      else # not a courier
        util.ctl('Main').killCourierPing()
        if util.ctl('Account').isManagedAccount()
          bodyTag.addCls 'managed-account'
          @hideTitles [4, 7, 8, 9, 10, 11]
          @showTitles [0, 2, 3]
        else # a normal user
          @hideTitles [8, 9, 10, 11]
          @showTitles [0, 2, 3, 4, 7]
      util.ctl('Account').populateAccountForm()
    else
      @hideTitles [2, 3, 4, 7, 8, 9, 10, 11]
      @showTitles [1] # Login page
