Ext.define('Ux.field.CreditCardField', {
  extend: 'Ext.field.Text',
  xtype: 'creditcardfield',
  onKeyUp: function() {
    var amex, i, nStr, nums, partOne, partThree, partTwo, r, value;
    value = this.getValue();
    nums = value.substr(0, 17).replace(/[^\d]/gi, '');
    amex = nums.match(/^3[47](\d){2}/g);
    if (amex) {
      partOne = amex[0];
      if (nums.length >= 10) {
        partTwo = nums.slice(4, 10);
      }
      if (nums.length === 15) {
        partThree = nums.slice(10);
      }
      if (partThree) {
        return this.setValue(partOne + ' ' + partTwo + ' ' + partThree);
      } else if (partTwo) {
        return this.setValue(nums.length > 10 ? partOne + ' ' + partTwo + ' ' + nums.substr(10) : partOne + ' ' + partTwo);
      } else if (partOne) {
        return this.setValue(nums.length > 4 ? partOne + ' ' + nums.substr(4) : partOne);
      }
    } else {
      nums = value.substr(0, 19).replace(/[^\d]/gi, '');
      r = nums.match(/(\d){4}/g);
      if (r) {
        i = 0;
        nStr = '';
        while (i < r.length) {
          nStr += i !== r.length - 1 ? r[i] + (i < 3 ? ' ' : '') : r[i];
          i++;
        }
        return this.setValue(nums.length % 4 !== 0 ? nStr + ' ' + nums.substr(r.length * 4, nums.length) : nStr);
      } else {
        return this.setValue(nums);
      }
    }
  }
});
