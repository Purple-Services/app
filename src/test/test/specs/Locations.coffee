Utils = require('./test_utils.js')

assert = require('assert')
sinon = require('sinon')

describe 'webdriver.io page', ->

  it 'should make an order', ->
    this.timeout(30000)
    Utils.login("Locations")

    browser.pause 250
    console.log 'should change home and work locations'
    Utils.getMenu 'div=Request Gas'
    console.log 'request gas menu'
    Utils.waitUntil 'visible', '#requestAddressField'
    Utils.waitUntil 'enabled', '#requestAddressField'
    browser.click '#requestAddressField'
    console.log 'request address field'
    Utils.waitUntil 'visible', '#changeHomeAddressButton'
    browser.click '#changeHomeAddressButton'
    console.log 'change home button'
    Utils.waitUntil 'visible', '#removeHomeAddress'
    browser.click '#removeHomeAddress'
    console.log 'remove home'
    Utils.waitUntil 'enabled', '#addHomeAddress'
    browser.click '#addHomeAddress'
    console.log 'add home button'
    Utils.waitUntil 'visible', '#requestAddressField'
    browser.setValue '[name="request_address"]', '424 Kelton Avenue Los Angeles CA'
    Utils.getList '.locationVicinity'
    console.log 'added home address'
    return

  return