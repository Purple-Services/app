Ext.define 'Purple.view.TopToolbar',
  extend: 'Ext.Toolbar'
  xtype: 'toptoolbar'
  config:
    docked: 'top'
    ui: 'top-toolbar'
    cls: 'slideable'
    height: 60
    title: """
      <img src="resources/images/logo-word.png" style="height: 42px; padding-top: 11px;" />
    """
    items: [
      {
        xtype: 'button'
        id: 'menuButton'
        ui: 'plain'
        handler: -> @fireEvent 'menuButtonTap'
      }
      {
        xtype: 'spacer'
      }
      {
        xtype: 'button'
        id: 'helpButton'
        ui: 'plain'
        handler: -> @fireEvent 'helpButtonTap'
      }
    ]
