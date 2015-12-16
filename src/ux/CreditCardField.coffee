Ext.define 'Ux.field.CreditCardField',
  extend: 'Ext.field.Text'
  xtype: 'creditcardfield'

  onKeyup: (value) ->
    nums = value.substr(0, 17).replace(/[^\d]/gi, '')
    amex = nums.match(/^3[47](\d){2}/g)

    if amex
      partOne = amex[0]
      if nums.length >= 10
        partTwo = nums.slice(4, 10)
      if nums.length is 15
        partThree = nums.slice(10)
      if partThree
        @setValue partOne + ' ' + partTwo + ' ' + partThree
      else if partTwo
        @setValue if nums.length > 10 then partOne + ' ' + partTwo + ' ' + nums.substr(10) else partOne + ' ' + partTwo
      else if partOne
        @setValue if nums.length > 4 then partOne + ' ' + nums.substr(4) else partOne
    
    else
      nums = value.substr(0, 19).replace(/[^\d]/gi, '') 
      r = nums.match(/(\d){4}/g)
      if r
        i = 0
        nStr = ''
        while i < r.length
          nStr += if i isnt r.length - 1 then r[i] + (if i < 3 then ' ' else '') else r[i]
          i++  
        @setValue if nums.length % 4 isnt 0 then nStr + ' ' + nums.substr(r.length * 4, nums.length) else nStr
      else
        @setValue nums

