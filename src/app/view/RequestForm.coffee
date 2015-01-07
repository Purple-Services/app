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
            xtype: 'component'
            flex: 0
            cls: 'heading'
            html: 'Request Gas'
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'selectfield'
            flex: 0
            name: 'time'
            label: 'Time'
            listPicker:
              title: 'Select a Time'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            value: '< 3 hr'
            options: [
              {
                text: 'within 1 hour'
                value: '< 1 hr'
              }
              {
                text: 'within 3 hours'
                value: '< 3 hr'
              }
            ]
          }
          {
            xtype: 'selectfield'
            flex: 0
            name: 'vehicle'
            label: 'Vehicle'
            listPicker:
              title: 'Select a Time'
            cls: [
              'click-to-edit'
              'bottom-margin'
            ]
            value: '123abc'
            options: [
              {
                text: 'Pontiac Trans Am'
                value: '123abc'
              }
              {
                text: 'Audi A4'
                value: 'hdj883'
              }
              {
                text: 'New Vehicle'
                value: 'add'
              }
            ]
          }
          {
            xtype: 'component'
            flex: 0
            cls: 'horizontal-rule'
          }
          {
            xtype: 'component'
            flex: 0
            html: 'Gallons'
            cls: 'field-label-text'
          }
          {
            xtype: 'component'
            flex: 0
            width: '100%'
            html: """
              <div class="tick-label-container">
                <div class="tick-label" style="margin-left: 0px;">5</div>
                <div class="tick-label" style="left: 50%;">10</div>
                <div class="tick-label" style="right: 0px;">15</div>
              </div>
            """
          }
          {
            xtype: 'sliderfield'
            id: 'gallons'
            flex: 0
            width: '100%'
            padding: 0
            margin: 0
            minValue: 5
            maxValue: 15
            increment: 5
            listeners:
              drag: (field, ignore, ignore2, newValue) ->
                #@adjustBrightness newValue
                true
              change: (field, ignore, ignore2, newValue) ->
                #@adjustBrightness newValue
                true
          }
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
          {
            xtype: 'container'
            id: 'sendRequestButtonContainer'
            flex: 0
            height: 110
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
                text: 'Send Request'
                flex: 0
                handler: ->
                  @up().fireEvent 'sendRequest'
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

