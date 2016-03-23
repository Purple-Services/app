Ext.define 'Purple.view.TopToolbar',
  extend: 'Ext.Toolbar'
  xtype: 'toptoolbar'
  config:
    docked: 'top'
    ui: 'top-toolbar'
    height: 60
    title: """
      <img src="resources/images/logo.png" style="height: 44px; padding-top: 10px;" />
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
        xtype: 'button'
        cls: 'courierOnDutyToggle'
        ui: 'plain'
        handler: -> @up().fireEvent 'courierOnDutyToggle'
      }
    ]
