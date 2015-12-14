Ext.define 'Ux.field.CreditCardField',
  extend: 'Ext.field.Text'
  xtype: 'creditcardfield'

  onKeyup: (value) ->
    nums = value.substr(0, 19).replace(/[^\d]/gi, '')
    r = nums.match(/(\d){4}/g)
    if r
      i = 0
      nStr = ''
      while i < r.length
        nStr += if i != r.length - 1 then r[i] + (if i < 3 then '-' else '') else r[i]
        i++
      @setValue if nums.length % 4 != 0 then nStr + '-' + nums.substr(r.length * 4, nums.length) else nStr
    else
      @setValue nums
