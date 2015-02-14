Ext.define 'Purple.view.RequestForm'
  extend: 'Ext.form.Panel'
  xtype: 'requestform'
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
            cls: 'heading'
            html: 'Request Gas'
            items: [
              {
                xtype: 'button'
                ui: 'plain'
                text: 'Back to Map'
                cls: [
                  'right-side-aligned-with-heading'
                  'link'
                ] 
                handler: ->
                  @up().up().up().fireEvent 'backToMap'
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
            ctype: 'requestFormVehicleSelect'
            flex: 0
            name: 'vehicle'
            label: 'Vehicle'
            listPicker:
              title: 'Select a Vehicle'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            options: [
            ]
          }
          {
            xtype: 'selectfield'
            ctype: 'requestFormGallonsSelect'
            flex: 0
            name: 'gallons'
            label: 'Gallons'
            listPicker:
              title: 'Number of Gallons'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
            ]
            disabled: yes
            options: [
            ]
          }
          {
            xtype: 'selectfield'
            ctype: 'requestFormTimeSelect'
            flex: 0
            name: 'time'
            label: 'Time'
            listPicker:
              title: 'Select a Time'
            cls: [
              'click-to-edit'
              'bottom-margin'
              'visibly-disabled'
            ]
            disabled: yes
            options: [
            ]
          }
          # {
          #   xtype: 'component'
          #   flex: 0
          #   cls: 'horizontal-rule'
          # }
          # {
          #   xtype: 'component'
          #   flex: 0
          #   html: 'Gallons'
          #   cls: 'field-label-text'
          # }
          # {
          #   xtype: 'sliderfield'
          #   id: 'gallons'
          #   flex: 0
          #   width: '100%'
          #   padding: 0
          #   margin: 0
          #   minValue: 5
          #   maxValue: 15
          #   increment: 5
          #   listeners:
          #     drag: (field, ignore, ignore2, newValue) ->
          #       #@adjustBrightness newValue
          #       true
          #     change: (field, ignore, ignore2, newValue) ->
          #       #@adjustBrightness newValue
          #       true
          # }
          # {
          #   xtype: 'component'
          #   flex: 0
          #   width: '100%'
          #   html: """
          #     <div class="tick-label-container">
          #       <div class="tick-label" style="margin-left: 0px;">5</div>
          #       <div class="tick-label" style="left: 50%;">10</div>
          #       <div class="tick-label" style="right: 0px;">15</div>
          #     </div>
          #   """
          # }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'component'
            flex: 0
            html: 'Special Instructions'
            cls: 'field-label-text'
          }
          {
            xtype: 'textareafield'
            name: 'special_instructions'
            maxRows: 4
          }
          
          # hidden fields for flowing data
          {
            xtype: 'hiddenfield'
            name: 'lat'
          }
          {
            xtype: 'hiddenfield'
            name: 'lng'
          }
          {
            xtype: 'hiddenfield'
            name: 'address_street'
          }
          
          {
            xtype: 'container'
            id: 'sendRequestButtonContainer'
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
                ctype: 'sendRequestButton'
                ui: 'action'
                cls: 'button-pop'
                text: 'Send Request'
                disabled: yes
                flex: 0
                handler: ->
                  @up().up().up().fireEvent 'sendRequest'
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

