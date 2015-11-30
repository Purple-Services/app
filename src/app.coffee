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
    'Override.ux.Map'
    'Ux.field.SelectOtherField'
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
    'GasTanks'
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
    # clean out that preload div, we no longer need those there
    #document.getElementById('images-to-preload').innerHTML = ""
