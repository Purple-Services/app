Ext.define 'Purple.view.TopToolbar',
  extend: 'Ext.Toolbar'
  xtype: 'toptoolbar'
  config:
    docked: 'top'
    ui: 'top-toolbar'
    height: 60
    title: """
      <img src="resources/images/logo.png" style="height: 43px; padding-top: 8px;" />
    """
    items: [
      {
        xtype: 'button'
        ctype: 'menuButton'
        cls: 'menuButton'
        ui: 'plain'
        handler: -> @up().fireEvent 'menuButtonTap'
      }
      {
        xtype: 'spacer'
      }
      {
        xtype: 'button'
        cls: 'freeGasButton'
        ui: 'plain'
        handler: -> @up().fireEvent 'freeGasButtonTap'
      }
      {
        xtype: 'togglefield'
        ctype: 'onDutyToggle'
        cls: 'onDutyToggle'
        ui: 'plain'
      }
    ]
