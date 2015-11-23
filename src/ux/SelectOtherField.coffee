Ext.define 'Ux.field.SelectOtherField',
  extend: 'Ext.field.Select'
  xtype: 'selectotherfield'

  config:
    otherText: 'Other...'
    promptTitle: 'New Option'
    promptMessage: 'Enter new option:'

  addOtherField: ->
    opts = @getOptions()
    i = 0
    while i < opts.length
      if opts[i] == @getOtherText()
        return
      i++
    opts.push
      text: @getOtherText()
      value: @getOtherText()
    @updateOptions opts
    @optionsAdded = true

  fieldChange: (cmp, newValue) ->
    if newValue is @getOtherText()
      Ext.Msg.prompt @getPromptTitle(), @getPromptMessage(), (choice, text) =>
        if choice is 'ok' and text.trim() isnt ''
          @insertOption text
        if choice is 'cancel'
          @setValue ''

  insertOption: (text) ->
    util.ctl("Vehicles").updateVehicleList(@_name, text)

