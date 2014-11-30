Ext.define 'Purple.view.TopToolbar',
  extend: 'Ext.Toolbar'
  xtype: 'toptoolbar'
  config:
    docked: 'top'
    ui: 'top-toolbar'
    title: 'Purple'
    items: [
      {
        xtype: 'button'
        ctype: 'infoButton'
        cls: 'light'
        ui: 'plain'
        iconCls: 'icomoon-jared-mdstand'
        iconMask: yes
        handler: -> @fireEvent 'infoButtonTap'
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
