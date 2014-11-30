Ext.define 'Purple.controller.TopToolbar'
  extend: 'Ext.app.Controller'
  requires: [
    'Purple.view.MainContainer'
    'Purple.view.TopToolbar'
  ]
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      backButton: '[ctype=backButton]'
      infoButton: '[ctype=infoButton]'
    control:
      backButton:
        backButtonTap: 'backButtonTap'
      infoButton:
        infoButtonTap: 'infoButtonTap'

  backButtonTap: ->
    @getBackButton().config.performAction()

  helpButtonTap: ->
    text =  @getMainContainer().getActiveItem().config.helpText ? """
      No help info here.
    """
    Ext.Msg.alert 'Help?', text, (->)
