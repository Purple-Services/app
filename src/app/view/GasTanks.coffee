Ext.define 'Purple.view.GasTanks',
  extend: 'Ext.form.Panel'
  xtype: 'gastanks'
  requires: [
    'Ext.form.*'
    'Ext.field.*'
    'Ext.Button'
  ]
  config:
    layout:
      type: 'hbox'
      pack: 'start'
      align: 'start'
    height: '100%'
    submitOnAction: no
    cls: [
      'request-form'
      'vehicle-form'
      'view-order'
      'gas-tanks'
      'accent-bg'
      'slideable'
    ]
    scrollable:
      direction: 'vertical'
      directionLock: yes
      translatable:
        translationMethod: 'auto'
    items: [
      {
        xtype: 'spacer'
        flex: 1
      }
      {
        xtype: 'container'
        flex: 0
        width: '85%'
        layout:
          type: 'vbox'
          pack: 'start'
          align: 'start'
        items: [
          {
            xtype: 'component'
            flex: 0
            cls: 'heading'
            html: 'Gas Tanks'
          }
          {
            xtype: 'component'
            flex: 0
            cls: [
              'horizontal-rule'
              'purple-rule'
            ]
          }
          {
            xtype: 'ratingfield'
            ctype: 'gasTanks87'
            flex: 0
            name: 'gas_tanks_87'
            label: '87 Oct.'
            labelWidth: 75
            cls: [
              'big-and-bold'
              'no-background'
            ]
          }
          {
            xtype: 'ratingfield'
            ctype: 'gasTanks91'
            flex: 0
            name: 'gas_tanks_91'
            label: '91 Oct.'
            labelWidth: 75
            cls: [
              'big-and-bold'
              'no-background'
            ]
          }
          {
            xtype: 'container'
            ctype: 'gasTanksSaveButtonContainer'
            flex: 0
            height: 110
            width: '100%'
            padding: '0 0 5 0'
            layout:
              type: 'vbox'
              pack: 'center'
              align: 'center'
            items: [
              {
                xtype: 'button'
                ctype: 'gasTanksSaveButton'
                ui: 'action'
                cls: 'button-pop'
                text: 'Save Changes'
                flex: 0
                disabled: yes
                handler: ->
                  @up().up().up().fireEvent 'saveChanges'
              }
            ]
          }
          {
            xtype: 'component'
            flex: 0
            html: """
              Only update gas tanks when filling up tanks. When you complete a
              gas delivery, your gas tank status will be automatically adjusted.
            """
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]

