Ext.define 'Purple.view.TopToolbar',
  extend: 'Ext.Toolbar'
  xtype: 'toptoolbar'
  config:
    docked: 'top'
    ui: 'top-toolbar'
    height: 60
    title: """
      <img src="resources/images/logo-word.png" style="height: 42px; padding-top: 11px;" />
    """
    items: [
      {
        xtype: 'button'
        ctype: 'infoButton'
        ui: 'plain'
        iconCls: 'icomoon-spinner'
        iconMask: yes
        handler: -> @fireEvent 'infoButtonTap'
      }
      {
        xtype: 'spacer'
      }
      {
        xtype: 'button'
        ctype: 'helpButton'
        ui: 'plain'
        iconCls: 'icomoon-jared-question'
        iconMask: yes
        handler: -> @fireEvent 'helpButtonTap'
      }
    ]
