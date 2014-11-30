Ext.define 'Purple.view.MainContainer',
  extend: 'Ext.Container'
  xtype: 'maincontainer'
  config:
    cls: 'accent-bg'
    layout:
      type: 'card'
  initialize: ->
    @callParent arguments
