Ext.define('Ux.field.MoneyField', {
  extend: 'Ext.field.Text',
  xtype: 'moneyfield',
  applyValue: function(value) {
    return Ext.util.Format.format('${0}', value);
  }
});
