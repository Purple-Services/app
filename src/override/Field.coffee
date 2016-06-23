Ext.define 'Override.field.Field',
  override: 'Ext.field.Field'

  initialize: (field) ->
    @callParent()
    for child in [0...@element.dom.children.length]
      if @element.dom.children[child].className is "x-form-label"
        @element.dom.children[child].onclick = (=> @focus?())