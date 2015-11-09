Ext.define('Ux.field.SelectOtherField', {
  extend: 'Ext.field.Select',
  xtype: 'selectotherfield',
  config: {
    otherText: 'Other...',
    promptTitle: 'New Option',
    promptMessage: 'Enter new option:'
  },
  initialize: function() {
    var opts;
    this.callParent();
    opts = this.getOptions();
    opts.push({
      text: this.getOtherText(),
      value: this.getOtherText()
    });
    return this.updateOptions(opts);
  },
  onChange: function(cmp, newValue) {
    this.callParent();
    if (newValue === this.getOtherText()) {
      return Ext.Msg.prompt(this.getPromptTitle(), this.getPromptMessage(), (function(_this) {
        return function(choice, text) {
          if (choice === 'ok' && text.trim() !== '') {
            _this.insertOption(text);
            return _this.setValue(text);
          }
        };
      })(this));
    }
  },
  insertOption: function(text) {
    var opts;
    opts = this.getOptions();
    opts.splice(-1, 0, {
      text: text,
      value: text
    });
    return this.updateOptions(opts);
  }
});
