Utils = require('./test_utils.js')

assert = require('assert')
sinon = require('sinon')

describe 'webdriver.io page', ->

  it 'should delete the order', ->
    this.timeout(30000)
    Utils.login("DeleteOrder")

    console.log 'should delete the order'
    Utils.getMenu 'div=Orders'
    Utils.getList '.order-list-item'
    console.log 'order clicked'
    browser.click 'span=Cancel Order'
    Utils.waitForAlert(true)
    console.log 'deleted'
    Utils.waitUntil 'visible', 'div=Orders'
    return

  return