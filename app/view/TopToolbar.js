Ext.define('Purple.view.TopToolbar', {
  extend: 'Ext.Toolbar',
  xtype: 'toptoolbar',
  config: {
    docked: 'top',
    ui: 'top-toolbar',
    height: 60,
    title: "<img src=\"resources/images/logo-word.png\" style=\"height: 42px; padding-top: 14px;\" />",
    items: [
      {
        xtype: 'button',
        ctype: 'menuButton',
        cls: 'menuButton',
        ui: 'plain',
        handler: function() {
          return this.up().fireEvent('menuButtonTap');
        }
      }, {
        xtype: 'spacer'
      }, {
        xtype: 'button',
        cls: 'freeGasButton',
        ui: 'plain',
        handler: function() {
          return this.up().fireEvent('freeGasButtonTap');
        }
      }
    ]
  }
});
