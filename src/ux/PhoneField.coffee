Ext.define 'Ux.field.PhoneField',
  extend: 'Ext.field.Text'
  xtype: 'phonefield'

  onKeyup: (value) ->
    nums = value.substr(0, 14).replace(/[^\d]/gi, '')
    if nums.length <= 3
      @setValue '(' + nums + ')'
    else if nums.length <= 6
      partOne = nums.slice(0, 3)
      partTwo = nums.slice(3)
      @setValue '(' + partOne + ')' + ' ' + partTwo
    else if nums.length <= 10
      partOne = nums.slice(0, 3)
      partTwo = nums.slice(3, 6)
      partThree = nums.slice(6)
      @setValue '(' + partOne + ')' + ' ' + partTwo + '-' + partThree

