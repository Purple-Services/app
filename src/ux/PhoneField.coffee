Ext.define 'Ux.field.PhoneField',
  extend: 'Ext.field.Text'
  xtype: 'phonefield'

  onKeyup: (value) ->
    s2 = (""+value).replace(/\D/g, '')
    m = s2.match(/^(\d{3})(\d{3})(\d{4})$/)
    console.log m
    (!m) ? null : "(" + m[1] + ") " + m[2] + "-" + m[3]
    @setValue m

  # applyValue: (value) ->
  #   Ext.util.Format.format '{0}', value
