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
      'vehicle-form'
      'accent-bg'
      'slideable'
    ]
    scrollable:
      direction: 'vertical'
      directionLock: yes
    listeners:
      initialize: ->
        if @config.vehicleId isnt 'new'
          @getAt(1).add [
            {
              xtype: 'spacer'
              flex: 0
              height: 100
            }
            {
              xtype: 'container'
              flex: 0
              layout:
                type: 'vbox'
                pack: 'start'
                align: 'center'
              cls: 'links-container'
              style: """
                width: 100%;
                text-align: center;
                padding-bottom: 20px;
              """
              items: [
                {
                  xtype: 'button'
                  ui: 'plain'
                  text: 'Delete Vehicle'
                  handler: =>
                    @fireEvent 'deleteVehicle', @config.vehicleId
                }
              ]
            }
          ]
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
            ctype: 'editVehicleFormHeading'
            cls: 'heading'
            html: ''
            items: [
              {
                xtype: 'button'
                ctype: 'backToVehiclesButton'
                ui: 'plain'
                text: 'Back to Vehicles'
                cls: [
                  'right-side-aligned-with-heading'
                  'link'
                ] 
                handler: (button) ->
                  if button.config.beforeHandler?
                    button.config.beforeHandler()
                    button.config.beforeHandler = null
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
            ctype: 'editVehicleFormYear'
            flex: 0
            name: 'year'
            label: 'Year'
            listPicker:
              title: 'Select Vehicle Year'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
            ]
            disabled: yes
            options: [
              'Loading...'
            ]
          }
          {
            xtype: 'selectfield'
            ctype: 'editVehicleFormMake'
            flex: 0
            name: 'make'
            label: 'Make'
            listPicker:
              title: 'Select Vehicle Make'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
            ]
            disabled: yes
            options: [
              'Please select year...'
            ]
          }
          {
            xtype: 'selectfield'
            ctype: 'editVehicleFormModel'
            flex: 0
            name: 'model'
            label: 'Model'
            listPicker:
              title: 'Select Vehicle Model'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
            ]
            disabled: yes
            options: [
              'Please select make...'
            ]
          }
          {
            xtype: 'selectfield'
            ctype: 'editVehicleFormColor'
            flex: 0
            name: 'color'
            label: 'Color'
            listPicker:
              title: 'Select Vehicle Color'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
            ]
            disabled: yes
            options: [
              'Loading...'
            ]
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'selectfield'
            ctype: 'editVehicleFormGasType'
            flex: 0
            name: 'gas_type'
            label: 'Gas'
            listPicker:
              title: 'Select Vehicle Gas'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            options: [
              {
                text: 'Unleaded 87 Octane'
                value: '87'
              }
              {
                text: 'Unleaded 91 Octane'
                value: '91'
              }
            ]
          }
          {
            xtype: 'textfield'
            ctype: 'editVehicleFormLicensePlate'
            name: 'license_plate'
            label: 'License Plate'
            labelWidth: 125
            flex: 0
            cls: [
              'bottom-margin'
              'uppercase-input'
            ]
            clearIcon: no
          }
          {
            xtype: 'hiddenfield'
            ctype: 'editVehicleFormPhoto'
            name: 'photo'
          }
          {
            xtype: 'button'
            ctype: 'editVehicleFormTakePhotoButton'
            ui: 'plain'
            cls: [
              'take-photo'
            ]
            text: 'Take Photo'
            handler: ->
              @fireEvent 'takePhoto'
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
                  @up().up().up().fireEvent 'saveChanges', @up().up().up().config.saveChangesCallback
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

