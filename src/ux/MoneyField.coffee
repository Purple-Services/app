Ext.define 'Ux.field.MoneyField',
  extend: 'Ext.field.Text'
  xtype: 'moneyfield'

  applyValue: (value) ->
    Ext.util.Format.format '${0}', value
