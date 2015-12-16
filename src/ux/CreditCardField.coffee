Ext.define 'Ux.field.CreditCardField',
  extend: 'Ext.field.Text'
  xtype: 'creditcardfield'

  onKeyup: (value) ->
    nums = value.substr(0, 19).replace(/[^\d]/gi, '')
    a1 = nums.match(/^3[47](\d){2}/g)
    a2 = nums.match(/^3[47](\d){8}/g)
    a3 = nums.match(/^3[47](\d){13}/g)

    if a1 or a2 or a3
      if a1 then partOne = a1[0]
      if a2 then partTwo = a2[0].slice(4, 10)
      if a3 then partThree = a3[0].slice(10)

      if partThree
        @setValue partOne + ' ' + partTwo + ' ' + partThree
      else if partTwo
        @setValue if nums.length > 10 then partOne + ' ' + partTwo + ' ' + nums.substr(10) else partOne + ' ' + partTwo
      else if partOne
        @setValue if nums.length > 4 then partOne + ' ' + nums.substr(4) else partOne
    
    else 
      r = nums.match(/(\d){4}/g)
      if r
        i = 0
        nStr = ''
        while i < r.length
          nStr += if i != r.length - 1 then r[i] + (if i < 3 then ' ' else '') else r[i]
          i++  
        @setValue if nums.length % 4 != 0 then nStr + ' ' + nums.substr(r.length * 4, nums.length) else nStr
      else
        @setValue nums

