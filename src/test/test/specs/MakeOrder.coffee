Utils = require('./test_utils.js')

assert = require('assert')
sinon = require('sinon')

describe 'webdriver.io page', ->

  it 'should make an order', ->
    this.timeout(60000)
    Utils.login("MakeOrder")

    browser.pause 250
    console.log 'should make an order'
    Utils.getMenu 'div=Request Gas'
    console.log 'request gas menu'
    Utils.waitUntil 'visible', '#requestGasButton'
    Utils.waitUntil 'enabled', '#requestGasButton'
    browser.click '#requestGasButton'
    console.log 'request gas button'
    Utils.waitUntil 'visible', '#sendRequestButtonContainer'
    Utils.waitUntil 'enabled', '#sendRequestButtonContainer'
    browser.click 'div=Time'
    browser.click 'span=within 3 hours ($3.99)'
    # clock = sinon.useFakeTimers(new Date(2016, 3, 29).getTime())
    # console.log new Date()
    console.log "about to click send request button"
    browser.pause 500
    browser.elementIdClick(browser.elements('#sendRequestButtonContainer .x-button').value[0].ELEMENT)
    browser.pause 500
    # clock.restore()
    # console.log new Date()
    console.log 'wait until confirm button visible'
    Utils.waitUntil 'visible', '#confirmOrderButtonContainer'
    browser.pause 500
    # clock = sinon.useFakeTimers(new Date(2016, 3, 29).getTime())
    # console.log new Date()
    console.log 'review order button'
    browser.pause 1000
    browser.elementIdClick(browser.elements('#confirmOrderButtonContainer .x-button').value[0].ELEMENT)
    browser.pause 500
    # clock.restore()
    # console.log new Date()
    # clock.restore()
    # console.log new Date()
    console.log 'after clicking confirm...'
    # Utils.waitForAlert(true)
    browser.pause 8000
    console.log 'hello'
    console.log browser.alertText()
    console.log 'clicked alert'
