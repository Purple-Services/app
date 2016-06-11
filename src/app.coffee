Ext.Loader.setPath
  'Ux.field': 'ux'
  'Ext.ux': 'ux'
  'Override.form': 'override'
  'Override.field': 'override'
  'Override.ux': 'override'

Ext.application
  name: 'Purple'
  requires: [
    'Ext.MessageBox'
    'Override.form.Panel'
    'Override.field.Select'
    'Override.field.Field'
    'Override.ux.Map'
    'Ux.field.SelectOtherField'
    'Ux.field.PhoneField'
    'Ux.field.CreditCardField'
    'Ux.field.MoneyField'
    'Ux.field.RatingField'
    'Purple.plugin.NonListPullRefresh'
    'Purple.util.SizeMonitor', # TEMP fix, Chrome 43 bug
    'Purple.util.PaintMonitor' # TEMP fix, Chrome 43 bug
  ]
  controllers: [
    'Main'
    'Menu'
    'Account'
    'Vehicles'
    'Orders'
    'PaymentMethods'
    'Subscriptions'
    'GasTanks'
    'GasStations'
  ]
  views: [
    'MainContainer'
    'TopToolbar'
  ]

  launch: ->
    # Initialize the main view
    Ext.Viewport.add [
      Ext.create 'Purple.view.MainContainer'
    ]
