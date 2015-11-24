Ext.define 'Override.field.Select',
  override: 'Ext.field.Select'
  
  onFocus: (e) ->
    if this.getDisabled()
      return false

    component = this.getComponent()
    # this.fireEvent 'focus', this, e

    # if Ext.os.is.Android4
    #   component.input.dom.focus()
    component.input.dom.blur()

    this.isFocused = true
    this.showPicker()
    #e.preventDefault() # I added this but doesn't help the issue
    
  showPicker: ->
    if (Ext.os.is.iOS or Ext.os.is.Android) and not window.bypassListPicker
      window.plugins.listpicker.showPicker(
        {
          title: @config.listPicker.title
          # for some reason both "text" and "value" keys need to have only
          # Strings as values. I tried to use integers and the plugin fails.
          items: @getOptions()
          selectedValue: @getValue()
          doneButtonLabel: 'Done'
          cancelButtonLabel: 'Cancel'
        }
        (value) => @setValue value
        -> true
      )
    else
      console.log 'use sencha selectfield picker'
      `
        var me = this,
          store = me.getStore(),
          value = me.getValue();

      if (!store || store.getCount() === 0) {
          return;
      }

      if (me.getReadOnly()) {
          return;
      }

      me.isFocused = true;

      if (me.getUsePicker()) {
          var picker = me.getPhonePicker(),
              name = me.getName(),
              pickerValue = {};

          pickerValue[name] = value;
          picker.setValue(pickerValue);

          if (!picker.getParent()) {
              Ext.Viewport.add(picker);
          }

          picker.show();
      } else {
          var listPanel = me.getTabletPicker(),
              list = listPanel.down('list'),
              index, record;

          if (!listPanel.getParent()) {
              Ext.Viewport.add(listPanel);
          }

          listPanel.showBy(me.getComponent(), null);

          if (value || me.getAutoSelect()) {
              store = list.getStore();
              index = store.find(me.getValueField(), value, null, null, null, true);
              record = store.getAt(index);

              if (record) {
                  list.select(record, null, true);
              }
          }
      }
      `
      true
      
  # config:
    # listeners:
    #   focus: (field) ->
    #     console.log 'focus: ', field
        
    #     false
