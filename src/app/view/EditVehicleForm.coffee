Ext.define 'Purple.view.EditVehicleForm'
  extend: 'Ext.form.Panel'
  xtype: 'editvehicleform'
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
    submitOnAction: no
    cls: [
      'request-form'
      'accent-bg'
      'slideable'
    ]
    scrollable:
      direction: 'vertical'
      directionLock: yes
    listeners:
      initialize: ->
        heading = Ext.ComponentQuery.query('#editVehicleFormHeading')[0]
        heading.setHtml(
          if @config.vehicleId is 'new'
            'Add Vehicle'
          else
            'Edit Vehicle'
        )
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
            xtype: 'container'
            flex: 0
            id: 'editVehicleFormHeading'
            cls: 'heading'
            html: ''
            items: [
              {
                xtype: 'button'
                ui: 'plain'
                text: 'Back to Vehicles'
                cls: [
                  'right-side-aligned-with-heading'
                  'link'
                ] 
                handler: ->
                  @up().up().up().fireEvent 'backToVehicles'
              }
            ]
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'selectfield'
            flex: 0
            name: 'year'
            label: 'Year'
            listPicker:
              title: 'Select Vehicle Year'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            value: '2014'
            options: [
              {
                text: '2015'
                value: '2015'
              }
              {
                text: '2014'
                value: '2014'
              }
              {
                text: '2013'
                value: '2013'
              }
            ]
          }
          {
            xtype: 'selectfield'
            flex: 0
            name: 'make'
            label: 'Make'
            listPicker:
              title: 'Select Vehicle Make'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            value: 'Lexus'
            options: [
              {
                text: 'Lexus'
                value: 'Lexus'
              }
              {
                text: 'Audi'
                value: 'Audi'
              }
              {
                text: 'Honda'
                value: 'Honda'
              }
            ]
          }
          {
            xtype: 'selectfield'
            flex: 0
            name: 'model'
            label: 'Model'
            listPicker:
              title: 'Select Vehicle Model'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            value: 'ES 350'
            options: [
              {
                text: 'ES 350'
                value: 'ES 350'
              }
              {
                text: 'Pilot'
                value: 'Pilot'
              }
              {
                text: 'Civic'
                value: 'Civic'
              }
            ]
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'selectfield'
            flex: 0
            name: 'gas'
            label: 'Gas'
            listPicker:
              title: 'Select Vehicle Gas'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            value: '89'
            options: [
              {
                text: 'Unleaded 89 Octane'
                value: '89'
              }
              {
                text: 'Unleaded 91 Octane'
                value: '91'
              }
            ]
          }
          {
            xtype: 'textfield'
            name: 'license_plate'
            label: 'License Plate'
            flex: 0
            cls: [
              'bottom-margin'
            ]
            clearIcon: no
          }
          {
            xtype: 'button'
            ui: 'plain'
            text: 'take photo'
          }
          {
            xtype: 'container'
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
                ui: 'action'
                cls: 'button-pop'
                text: 'Save Changes'
                flex: 0
                handler: ->
                  @up().up().up().fireEvent 'saveChanges'
              }
            ]
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]

