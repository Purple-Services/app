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
        ui: 'top'
        iconCls: 'list'
        iconMask: yes
        handler: -> @fireEvent 'infoButtonTap'
      }
      {
        xtype: 'spacer'
      }
      {
        xtype: 'button'
        ctype: 'helpButton'
        ui: 'top'
        iconCls: 'icomoon-jared-question'
        iconMask: yes
        handler: -> @fireEvent 'helpButtonTap'
      }
    ]
