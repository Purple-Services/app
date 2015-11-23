Ext.define 'Ux.field.SelectOtherField',
  extend: 'Ext.field.Select'
  xtype: 'selectotherfield'

  config:
    otherText: 'Other...'
    promptTitle: 'New Option'
    promptMessage: 'Enter new option:'

  addOtherField: ->
    opts = @getOptions()
    for i in opts
      if i.value == @getOtherText()
        return
    opts.push
      text: @getOtherText()
      value: @getOtherText()
    @updateOptions opts

  fieldChange: (cmp, newValue) ->
    if newValue is @getOtherText()
      Ext.Msg.prompt @getPromptTitle(), @getPromptMessage(), (choice, text) =>
        if choice is 'ok' and text.trim() isnt ''
          opts = @getOptions()
          for i in opts
            if i.value.toUpperCase() == text.toUpperCase()
              @setValue text
              return
          @insertOption text
        if choice is 'cancel'
          @setValue ''

  insertOption: (text) ->
    util.ctl("Vehicles").updateVehicleList(@_name, text)

