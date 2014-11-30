Ext.define 'Purple.view.RequestForm'
  extend: 'Ext.form.Panel'
  xtype: 'requestform'
  requires: [
    'Ext.form.*'
    'Ext.field.*'
    'Ext.Button'
  ]
  config:
    layout: 'vbox'
    submitOnAction: yes
    items: [
      {
        xtype: 'textfield'
        name: 'time'
      }
    ]
