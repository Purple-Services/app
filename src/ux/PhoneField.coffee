Ext.define 'Ux.field.PhoneField',
  extend: 'Ext.field.Text'
  xtype: 'phonefield'

  onKeyUp: ->
    value = @getValue()
    nums = value.substr(0, 30).replace(/[^\d]/gi, '')
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
      if countryCodeLength < 4
        partOne = nums.slice(0, countryCodeLength)
        partTwo = nums.slice(countryCodeLength, countryCodeLength + 3)
        partThree = nums.slice(countryCodeLength + 3, countryCodeLength + 6)
        partFour = nums.slice(countryCodeLength + 6)
        @setValue '+' + partOne + ' (' + partTwo + ') ' + partThree + '-' + partFour
      else
        partOne = nums.slice(0, 3)
        partTwo = nums.slice(3, 6)
        partThree = nums.slice(6, 10)
        partFour = nums.slice(10)
        @setValue '+' + partOne + ' (' + partTwo + ') ' + partThree + '-' + partFour

    if nums.charAt(0) is '1'
      if nums.length <= 4
        @setValue '+' + nums
      else if nums.length <= 7
        partOne = nums.slice(1, 4)
        partTwo = nums.slice(4)
        @setValue '+1 (' + partOne + ') ' + partTwo
      else if nums.length <= 11
        partOne = nums.slice(1, 4)
        partTwo = nums.slice(4, 7)
        partThree = nums.slice(7)
        @setValue '+1 (' + partOne + ') ' + partTwo + '-' + partThree


    