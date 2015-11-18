// Generated by CoffeeScript 1.10.0
Ext.Loader.setPath({
  'Ux.field': 'ux',
  'Ext.ux': 'ux',
  'Override.form': 'override',
  'Override.field': 'override',
  'Override.ux': 'override'
});

Ext.application({
  name: 'Purple',
  requires: ['Ext.MessageBox', 'Override.form.Panel', 'Override.field.Select', 'Override.ux.Map', 'Ux.field.SelectOtherField', 'Ux.field.MoneyField', 'Ux.field.RatingField', 'Purple.plugin.NonListPullRefresh', 'Purple.util.SizeMonitor', 'Purple.util.PaintMonitor'],
  controllers: ['Main', 'Menu', 'Account', 'Vehicles', 'Orders', 'PaymentMethods', 'GasTanks'],
  views: ['MainContainer', 'TopToolbar'],
  launch: function() {
    return Ext.Viewport.add([Ext.create('Purple.view.MainContainer')]);
  }
});
