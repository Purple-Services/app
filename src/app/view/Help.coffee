Ext.define 'Purple.view.Help'
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
          "Do I need to be in my car when Purple is delivering gas?"
          "How long does it take to get my tank filled up?"
          "How do I know when the courier is enroute? Or when my car has been serviced?"
          "What type of gas can I order?"
          "How much gas can I get delivered?"
          "Is my payment secure when I order with my credit card?"
          "Should I be worried about my car's security during the delivery?"
          "What are your hours of operation?"
          "Can I cancel my order if I change my mind?"
          "What is the quality of the gas you sell?"
          "What happens if the driver doesn't find my car?"
          "What happens if the delivery is not done on time?"
        ]
        answers = [
          "Purple is a gas delivery service. Simply request gas and we will come to your vehicle and fill it up."
          "Purple is only available in the Los Angeles Metro area for now. We deliver gas to vehicles located in Westside."
          "Purple will always charge competitive gas prices available within the area we offer our service."
          "No. All you need to do is make sure that the gas tank door is open before the Purple courier fills up your tank."
          "Deliveries can be scheduled within 1 or 3 hours."
          "The purple app will send you several notifications and alerts to inform you about the progress of the delivery. A final message is sent to your phone to let you know that the delivery is completed and your gas tank has been filled up."
          "You can choose from 2 different types of gas quality. We deliver Unleaded 87 Octane and Unleaded 91 Octane."
          "Orders can be placed for a 10 gallons or 15 gallons delivery ONLY."
          "A secure method of payment enables you to pay by credit card. The data and transaction is encrypted with SSL and credit card numbers are not stored in our database."
          "Purple is in compliance with all safety and quality control measures from the Department of Transportation, Environmental Protection Agency, and local municipalities. All of our drivers will take a particular care to your vehicle and are fully insured, so you can have peace of mind that your vehicle is in the best hands possible."
          "Purple delivers gas from 10am to 9pm (PST)"
          "Orders can be cancelled anytime before gas begins pumping at no charge."
          "We only provide top tier gas. You can choose from Octane 87 and Octane 91."
          "Cars are located by the app and our drivers through your phone's GPS when you place the order. In case the address on file is different from the delivery site, the driver calls the user for more information. In case, the driver does not find your car, the delivery is cancelled at no charge."
          "If we are not able to deliver within the time slot that we have committed to, our driver will contact you to reschedule within your schedule or simply cancel the order."
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
        ###
      
         
          {
            xtype: 'textfield'
            flex: 0
            label: 'How do I become a courier?'
            labelWidth: '100%'
            cls: [
              #'click-to-edit'
              'bottom-margin'
            ]
            disabled: yes
            listeners:
              initialize: (field) ->
                field.element.on 'tap', ->
                  text = Ext.ComponentQuery.query('#q3text')[0]
                  if text.isHidden()
                    text.show()
                  else
                    text.hide()
          }
          {
            xtype: 'component'
            id: 'q3text'
            cls: 'accordion-text'
            showAnimation: 'fadeIn'
            hidden: yes
            html: 'If you are interested in becoming a courier for Purple Services and live in the Los Angeles area, please send an email to us at <a href="mailto:info@purpledelivery.com" target="_blank">info@purpledelivery.com</a>.'
          }
          {
            xtype: 'textfield'
            flex: 0
            label: 'How do I check the status of my current order?'
            labelWidth: '100%'
            cls: [
              #'click-to-edit'
              'bottom-margin'
            ]
            disabled: yes
            listeners:
              initialize: (field) ->
                field.element.on 'tap', ->
                  text = Ext.ComponentQuery.query('#q4text')[0]
                  if text.isHidden()
                    text.show()
                  else
                    text.hide()
          }
          {
            xtype: 'component'
            id: 'q4text'
            cls: 'accordion-text'
            showAnimation: 'fadeIn'
            hidden: yes
            html: 'To check on the status of a current or past order, please use the "Orders" tab.'
          }
          ###
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
            cls: 'horizontal-rule'
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]
