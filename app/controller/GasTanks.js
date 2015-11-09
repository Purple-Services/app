Ext.define('Purple.controller.GasTanks', {
  extend: 'Ext.app.Controller',
  requires: ['Purple.view.Order'],
  config: {
    refs: {
      mainContainer: 'maincontainer',
      topToolbar: 'toptoolbar',
      gasTanks: 'gastanks',
      gasTanks87: '[ctype=gasTanks87]',
      gasTanks91: '[ctype=gasTanks91]',
      gasTanksSaveButton: '[ctype=gasTanksSaveButton]'
    },
    control: {
      gasTanks: {
        saveChanges: 'saveChanges',
        initialize: 'setInitialValueFromLocalStorage'
      },
      gasTanks87: {
        change: 'gasTanksChanged'
      },
      gasTanks91: {
        change: 'gasTanksChanged'
      }
    }
  },
  launch: function() {
    return this.callParent(arguments);
  },
  setInitialValueFromLocalStorage: function() {
    return this.getGasTanks().setValues({
      gas_tanks_87: localStorage['purpleCourierGallons87'] / util.GALLONS_PER_TANK,
      gas_tanks_91: localStorage['purpleCourierGallons91'] / util.GALLONS_PER_TANK
    });
  },
  gasTanksChanged: function() {
    return this.getGasTanksSaveButton().setDisabled(false);
  },
  saveChanges: function() {
    var values;
    values = this.getGasTanks().getValues();
    localStorage['purpleCourierGallons87'] = values['gas_tanks_87'] * util.GALLONS_PER_TANK;
    localStorage['purpleCourierGallons91'] = values['gas_tanks_91'] * util.GALLONS_PER_TANK;
    return this.getGasTanksSaveButton().setDisabled(true);
  }
});
