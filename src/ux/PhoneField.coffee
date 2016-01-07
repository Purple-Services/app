Ext.define 'Ux.field.PhoneField',
  extend: 'Ext.field.Text'
  xtype: 'phonefield'

  onKeyup: (value) ->
    nums = value.substr(0, 19).replace(/[^\d]/gi, '')
    if nums.length <= 3
      @setValue nums
    else if nums.length <= 6
      partOne = nums.slice(0, 3)
      partTwo = nums.slice(3)
      @setValue ' (' + partOne + ') ' + partTwo
    else if nums.length <= 10
      partOne = nums.slice(0, 3)
      partTwo = nums.slice(3, 6)
      partThree = nums.slice(6)
      @setValue ' (' + partOne + ') ' + partTwo + '-' + partThree
    if nums.length > 10
      countryCodeLength = nums.slice(11).length + 1
      partOne = nums.slice(0, countryCodeLength)
      partTwo = nums.slice(countryCodeLength, countryCodeLength + 3)
      partThree = nums.slice(countryCodeLength + 3, countryCodeLength + 6)
      partFour = nums.slice(countryCodeLength + 6)
      @setValue '+' + partOne + ' (' + partTwo + ') ' + partThree + '-' + partFour


    