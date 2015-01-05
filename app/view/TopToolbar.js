// Generated by CoffeeScript 1.3.3

Ext.define('Purple.view.TopToolbar', {
  extend: 'Ext.Toolbar',
  xtype: 'toptoolbar',
  config: {
    docked: 'top',
    ui: 'top-toolbar',
    height: 60,
    title: "<img src=\"resources/images/logo-word.png\" style=\"height: 42px; padding-top: 11px;\" />",
    items: [
      {
        xtype: 'button',
        id: 'menuButton',
        ui: 'plain',
        handler: function() {
          return this.fireEvent('menuButtonTap');
        }
      }, {
        xtype: 'spacer'
      }, {
        xtype: 'button',
        id: 'helpButton',
        ui: 'plain',
        handler: function() {
          return this.fireEvent('helpButtonTap');
        }
      }
    ]
  }
});
