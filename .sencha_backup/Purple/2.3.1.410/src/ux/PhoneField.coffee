Ext.define 'Ux.field.PhoneField'
  extend: 'Ext.field.Text'
  xtype: 'phonefield'

  applyValue: (value) ->
    Ext.util.Format.format '{0}', value
