// Generated by CoffeeScript 1.3.3

Ext.define('Override.field.Select', {
  override: 'Ext.field.Select',
  showPicker: function() {
    var _this = this;
    if ((Ext.os.is.iOS || Ext.os.is.Android) && !window.bypassListPicker) {
      console.log('config', {
        title: this.config.listPicker.title,
        items: this.getOptions(),
        selectedValue: this.getValue(),
        doneButtonLabel: 'Done',
        cancelButtonLabel: 'Cancel'
      });
      return window.plugins.listpicker.showPicker({
        title: this.config.listPicker.title,
        items: this.getOptions(),
        selectedValue: this.getValue(),
        doneButtonLabel: 'Done',
        cancelButtonLabel: 'Cancel'
      }, function(value) {
        return _this.setValue(value);
      }, function() {
        return true;
      });
    } else {
      console.log('use sencha selectfield picker');
      
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
      ;

      return true;
    }
  }
});
