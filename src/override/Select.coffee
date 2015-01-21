Ext.define 'Override.field.Select'
  override: 'Ext.field.Select'
  showPicker: ->
    if (Ext.os.is.iOS or Ext.os.is.Android) and not window.bypassListPicker
      window.plugins.listpicker.showPicker(
        {
          title: @config.listPicker.title
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
