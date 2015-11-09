Ext.define('Ux.field.PhoneField', {
  extend: 'Ext.field.Text',
  xtype: 'phonefield',
  applyValue: function(value) {
    return Ext.util.Format.format('{0}', value);
  }
});
