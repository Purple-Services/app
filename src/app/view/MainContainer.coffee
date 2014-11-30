Ext.define 'Purple.view.MainContainer',
  extend: 'Ext.Container'
  xtype: 'maincontainer'
  config:
    layout:
      type: 'card'
  initialize: ->
    @callParent arguments
