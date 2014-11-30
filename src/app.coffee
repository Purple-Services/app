Ext.Loader.setPath
  'Ux.field': 'ux'
  'Override.form': 'override'

Ext.application
  name: 'Purple'
  requires: [
    'Override.form.Panel'
    'Ux.field.Multiselect'
    'Ux.field.SelectOtherField'
    'Ux.field.MultiSelectOtherField'
    'Ux.field.AutocompleteField'
  ]
  controllers: [
    'Main'
    'TopToolbar'
  ]
  views: [
    'MainContainer'
    'TopToolbar'
  ]

  launch: ->
    # Initialize the main view
    Ext.Viewport.add [
      Ext.create 'MDStand.view.TopToolbar'
      Ext.create 'MDStand.view.MainContainer'
    ]
