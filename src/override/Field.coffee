Ext.define 'Override.field.Field',
  override: 'Ext.field.Field'

  initialize: (field) ->
    @callParent()
    @element.on 'tap', => 
      @focus()
