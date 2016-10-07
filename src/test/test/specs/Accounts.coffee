Utils = require('./test_utils.js')

assert = require('assert')
sinon = require('sinon')

describe 'webdriver.io page', ->
  it 'should have the right title', ->
    console.log 'should have the right title'
    #change URL to file location
    browser.url 'file:///Users/celwell/purple/app/index-debug.html'
    title = browser.getTitle()
    assert.equal title, 'Purple'
    return

  it 'should login', ->
    console.log 'should login line#16'
    Utils.getMenu 'div=Login'
    console.log 'choose login'
    browser.setValue '.x-input-email', 'patrick@purpleapp.com'
    browser.setValue '.x-input-password', 'patrick'
    console.log 'login info'
    browser.click '#loginButtonContainer'
    console.log 'login'
    Utils.waitUntil 'visible', '#requestGasButton'
    return

  it 'should test accounts', ->
    console.log 'should test accounts'
    Utils.getMenu 'div=Account'
    console.log 'go to account'
    name = browser.getValue '[name="name"]'
    console.log 'Name: ' + name[1]
    assert.equal name[1], 'Patrick Tan'
    phone = browser.getValue '[name="phone_number"]'
    console.log 'Phone: ' + phone[1]
    assert.equal phone[1], '(714) 864 9041'
    return

  it 'should register a credit card', ->
    this.timeout(30000)
    console.log 'should register a credit card'
    Utils.getMenu 'div=Account'
    console.log 'go to account'
    browser.click 'div=Payment'
    console.log 'click on credit card'
    browser.waitUntil 'visible', 'span=Add Card'
    browser.click 'span=Add Card'
    console.log 'click add card'
    browser.setValue '[name="card_number"]', '4242424242424242'
    browser.setValue '[name="card_cvc"]', '123'
    browser.setValue '[name="card_billing_zip"]', '90024'
    console.log 'fill in text'
    browser.click 'div=Exp. Month'
    browser.click 'span=6 (June)'
    console.log 'month set to 6 (June)'
    Utils.waitUntil 'value', '[name="card_exp_month"]'
    browser.click 'div=Exp. Year'
    browser.click 'span=2020'
    console.log 'year set to 2020'
    Utils.waitUntil 'value', '[name="card_exp_year"]'
    browser.click 'span=Save Changes'
    Utils.waitUntil 'visible', '[name="payment_method"]', 30000
    return

  it 'should delete a credit card', ->
    console.log 'should delete a credit card'
    Utils.getMenu 'div=Account'
    console.log 'go to account'
    browser.click 'div=Payment'
    console.log 'click on credit card'
    browser.waitUntil 'visible', 'div=Visa*4242'
    browser.click 'div=Visa *4242'
    Utils.waitForAlert(true)
    Utils.waitForAlert(true)
    console.log 'alerts clicked'
    Utils.hitBack()
    console.log 'back clicked'
    return

  return

