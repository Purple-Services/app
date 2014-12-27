Ext.Loader.setPath
  'Ux.field': 'ux'
  'Ext.ux': 'ux'
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
    'Account'
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
