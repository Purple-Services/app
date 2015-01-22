Ext.define 'Purple.controller.Menu'
  extend: 'Ext.app.Controller'
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      feedbackButton: '[ctype=feedbackButton]'
      requestGasTabContainer: '#requestGasTabContainer'
      accountTab: '#accountTab'
      accountTabContainer: '#accountTabContainer'
      loginForm: 'loginform'
      mapForm: 'mapform'
      map: '#gmap'
    control:
      feedbackButton:
        feedbackButtonTap: 'feedbackButtonTap'
      topToolbar:
        menuButtonTap: 'menuButtonTap'
        helpButtonTap: 'helpButtonTap'

  launch: ->
    @callParent arguments

  menuButtonTap: ->
    @getMainContainer().toggleContainer()

  helpButtonTap: ->
    @selectOption 5

  feedbackButtonTap: ->
    @selectOption 6

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

  adjustForAppLoginState: ->
    if util.ctl('Account').isUserLoggedIn()
      @hideTitles [1]
      @showTitles [2, 3, 4]
      util.ctl('Account').populateAccountForm()
    else
      @hideTitles [2, 3, 4]
      @showTitles [1]

  # getCurrentTopToolbar: ->
  #   allTopToolbars = @getMainContainer().query('[xtype=toptoolbar]')
  #   for t in allTopToolbars
  #     console.log t.removeCls 'shadowed'
