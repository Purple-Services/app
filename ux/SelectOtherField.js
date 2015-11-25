Ext.define('Ux.field.SelectOtherField', {
  extend: 'Ext.field.Select',
  xtype: 'selectotherfield',
  config: {
    otherText: 'Other...',
    promptTitle: 'New Option',
    promptMessage: 'Enter new option:'
  },
  addOtherField: function() {
    var i, j, len, opts;
    opts = this.getOptions();
    for (j = 0, len = opts.length; j < len; j++) {
      i = opts[j];
      if (i.value === this.getOtherText()) {
        return;
      }
    }
    opts.push({
      text: this.getOtherText(),
      value: this.getOtherText()
    });
    return this.updateOptions(opts);
  },
  fieldChange: function(cmp, newValue) {
    if (newValue === this.getOtherText()) {
      return Ext.Msg.prompt(this.getPromptTitle(), this.getPromptMessage(), (function(_this) {
        return function(choice, text) {
          var i, j, len, opts;
          if (choice === 'ok' && text.trim() !== '') {
            opts = _this.getOptions();
            for (j = 0, len = opts.length; j < len; j++) {
              i = opts[j];
              if (i.value.toUpperCase() === text.toUpperCase()) {
                _this.setValue(text);
                return;
              }
            }
            _this.insertOption(text);
          }
          if (choice === 'cancel' || !text.trim()) {
            return _this.setValue('');
          }
        };
      })(this));
    }
  },
  insertOption: function(text) {
    return util.ctl("Vehicles").updateVehicleList(this._name, text);
  }
});
