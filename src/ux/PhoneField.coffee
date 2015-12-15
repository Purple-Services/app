Ext.define 'Ux.field.PhoneField',
  extend: 'Ext.field.Text'
  xtype: 'phonefield'

  onKeyup: (value) ->
    nums = value.substr(0, 19).replace(/[^\d]/gi, '')
    

  # applyValue: (value) ->
  #   Ext.util.Format.format '{0}', value
