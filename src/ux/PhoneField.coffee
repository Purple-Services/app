Ext.define 'Ux.field.PhoneField',
  extend: 'Ext.field.Text'
  xtype: 'phonefield'

  applyValue: (value) ->
    console.log 'called', value
    value = value.replace(/(\d{3})\-?(\d{3})\-?(\d{4})/,'($1) $2-$3')
    # Ext.util.Format.format '{0}', value 
