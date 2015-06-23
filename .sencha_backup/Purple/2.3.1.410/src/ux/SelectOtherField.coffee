Ext.define 'Ux.field.SelectOtherField'
  extend: 'Ext.field.Select'
  xtype: 'selectotherfield'

  config:
    otherText: 'Other...'
    promptTitle: 'New Option'
    promptMessage: 'Enter new option:'

  initialize: ->
    @callParent()
    opts = @getOptions()
    opts.push
      text: @getOtherText()
      value: @getOtherText()
    @updateOptions opts

  onChange: (cmp, newValue) ->
    @callParent()
    if newValue is @getOtherText()
      Ext.Msg.prompt @getPromptTitle(), @getPromptMessage(), (choice, text) =>
        if choice is 'ok' and text.trim() isnt ''
          @insertOption text
          @setValue text

  insertOption: (text) ->
    opts = @getOptions()
    opts.splice -1, 0,
      text: text
      value: text
    @updateOptions opts
