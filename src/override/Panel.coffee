Ext.define 'Override.form.Panel',
  override: 'Ext.form.Panel'
  getElementConfig: ->
    config = this.callParent()
    config.tag = "div"
    config.children.push
        tag: 'input'
        type: 'submit'
        style: 'visibility: hidden; width: 0; height: 0; position: absolute; right: 0; bottom: 0;'
    return config
  submit: (options, e) ->
    return false
    options = options || {}
    return this.callParent([options, e])
