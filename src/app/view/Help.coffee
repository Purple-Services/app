Ext.define 'Purple.view.Help',
  extend: 'Ext.Container'
  xtype: 'help'
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
      'accent-bg'
      'slideable'
    ]
    scrollable:
      direction: 'vertical'
      directionLock: yes
    listeners:
      initialize: ->
        questions = [
          "What is Purple?"
          "What is the area of service covered by Purple?"
          "What is the average gas price offered by Purple?"
          "Do I need to be in my car when Purple is delivering fuel?"
          "How long does it take to get my tank filled up?"
          "How do I know when the courier is enroute? Or when my car has been serviced?"
          "What kind of fuel will the service provider supply?"
          "How much fuel will be provided?"
          "How secure is my credit card information?"
          "Should I be worried about my car's security during the delivery?"
          "What are your hours of operation?"
          "Can I cancel my order if I change my mind?"
          "How will the service provider find my car?"
        ]
        answers = [
          "Purple provides on-demand filling services. Simply request gas and we will come to your vehicle and fill it up."
          "Purple is currently available in Los Angeles, Orange County, San Diego, and Seattle. More cities coming soon!"
          "Our prices are competitive with the average fuel cost in your area."
          "No. All you need to do is make sure that the gas tank door is open before the Purple service provider fills your tank. Don't worry, we'll make sure it's tightly shut when we finish!"
          "Deliveries can be scheduled within 1 or 3 hours."
          "Your app will keep you up to date on the progress of your service. Make sure your notifications are turned on so you don't miss these updates!"
          "You can choose between unleaded 87 octane or unleaded 91 octane fuel."
          "Choose between a 7 1/2, 10, or 15 gallons per delivery."
          "Your credit card information is very secure. The transaction is encrypted with SSL. Credit card numbers are not stored in our database."
          "No. Purple service providers are required to comply with all Department of Transportation, Environmental Protection Agency, and local municipalities safety and quality control measures. All of our service providers take pride in providing quality service, and protecting your vehicle. Service providers are fully insured."
          "We accept orders from 7:30am to 10:30pm (PST) in most areas."
          "Orders can be canceled at any time before servicing has started at no charge."
          "The service provider will find your car at the location where you place the pin on the map. If they have any trouble finding it they'll contact you for additional information."
        ]
        items = []
        for q, question of questions
          answer = answers[q]
          items.push
            xtype: 'textfield'
            flex: 0
            label: question
            labelWidth: '100%'
            cls: [
              'bottom-margin'
              'faq-question'
            ]
            disabled: yes
            q: q
            listeners:
              initialize: (field) ->
                field.element.on 'tap', ->
                  text = Ext.ComponentQuery.query("#q#{field.config.q}text")[0]
                  if text.isHidden()
                    text.show()
                  else
                    text.hide()
          items.push
            xtype: 'component'
            id: "q#{q}text"
            cls: 'accordion-text'
            showAnimation: 'fadeIn'
            hidden: yes
            html: answer
            
        Ext.getCmp('helpFaqContainer').add items
    items: [
      {
        xtype: 'spacer'
        flex: 1
      }
      {
        xtype: 'container'
        id: 'helpFaqContainer'
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
            html: 'Help / FAQ<span style="text-transform: lowercase;">s</span>'
          }
          {
            xtype: 'component'
            flex: 0
            cls: [
              'horizontal-rule'
              'purple-rule'
            ]
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]
