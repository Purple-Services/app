assert = require('assert')
assert = require('assert')

describe 'webdriver.io page', ->
  it 'should have the right title', ->
    console.log 'should have the right title'
    browser.url 'file:///Users/Patrick/Desktop/purple-app/index-debug.html'
    title = browser.getTitle()
    assert.equal title, 'Purple'
    return

  it 'should login', ->
    console.log 'should login'
    getMenu 'div=Login'
    console.log 'choose login'
    browser.setValue '.x-input-email', 'patrick@purpleapp.com'
    browser.setValue '.x-input-password', 'patrick'
    console.log 'login info'
    browser.click '#loginButtonContainer'
    console.log 'login'
    waitUntil 'visible', '#requestGasButton'
    return

  it 'should test accounts', ->
    console.log 'should test accounts'
    getMenu 'div=Account'
    console.log 'go to account'
    name = browser.getValue '[name="name"]'
    console.log 'Name: ' + name[1]
    assert.equal name[1], 'Patrick Tan'
    phone = browser.getValue '[name="phone_number"]'
    console.log 'Phone: ' + phone[1]
    assert.equal phone[1], '(714) 864 9041'
    return

  it 'should make an order', ->
    browser.pause 250
    console.log 'should make an order'
    getMenu 'div=Request Gas'
    console.log 'request gas menu'
    waitUntil 'visible', '#requestGasButton'
    waitUntil 'enabled', '#requestGasButton'
    browser.click '#requestGasButton'
    console.log 'request gas button'
    waitUntil 'visible', '#sendRequestButtonContainer'
    waitUntil 'enabled', '#sendRequestButtonContainer'
    browser.click '#sendRequestButtonContainer'
    waitUntil 'visible', '#confirmOrderButtonContainer'
    console.log 'review order button'
    browser.click '#confirmOrderButtonContainer'
    console.log 'confirm order'
    waitForAlert()
    console.log browser.alertText()
    browser.alertAccept()
    console.log 'clicked alert'
    waitUntil 'visible', 'div=Orders'
    return

  it 'should delete the order', ->
    console.log 'should delete the order'
    getMenu 'div=Orders'
    getList '.order-list-item'
    console.log 'order clicked'
    browser.click 'span=Cancel Order'
    waitForAlert()
    console.log browser.alertText()
    browser.alertAccept()
    console.log 'deleted'
    waitUntil 'visible', 'div=Orders'
    return

  it 'should create a new car', ->
    console.log 'should create a new car'
    getMenu 'div=Vehicles'
    console.log 'go to vehicles'
    browser.click 'span=Add Vehicle'
    browser.click 'div=Year'
    browser.click 'span=2016'
    console.log 'year set to 2016'
    waitUntil 'value', '[name="year"]'
    browser.click 'div=Make'
    browser.click 'span=Acura'
    console.log 'make set to Acura'
    waitUntil 'value', '[name="make"]'
    browser.click 'div=Model'
    browser.click 'span=MDX'
    console.log 'Model set to MDX'
    waitUntil 'value', '[name="model"]'
    browser.click 'div=Color'
    browser.click 'span=White'
    console.log 'color set to white'
    waitUntil 'value', '[name="color"]'
    browser.setValue '[name="license_plate"]', '1ABC234'
    console.log 'license plate set'
    browser.click 'span=Save Changes'
    waitUntil 'visible', 'span=2016 Acura MDX'
    return


  it 'should delete the newest car', ->
    console.log 'should delete the new car'
    getMenu 'div=Vehicles'
    console.log 'go to vehicles'
    getList '.vehicle-list-item'
    console.log 'car clicked'
    browser.click 'span=Delete Vehicle'
    waitForAlert()
    console.log browser.alertText()
    browser.alertAccept()
    console.log 'deleted'
    waitUntil 'visible', 'span=Add Vehicle'
    return

  return

getMenu = (divName) ->
  menus = browser.elements '.menuButton'
  returnMenu = menus.value[menus.value.length - 1].ELEMENT
  browser.elementIdClick returnMenu
  browser.pause 250 #wait for menu to stop moving
  browser.click divName
  console.log 'menu click'
  return

getList = (className) ->
  list = browser.elements className
  clickList = list.value[0].ELEMENT
  browser.elementIdClick clickList
  console.log 'list click'
  browser.pause 250 #wait for menu to stop moving
  return

waitUntil = (func, selector) ->
  switch func
    when 'visible' then browser.waitForVisible selector
    when 'value' then browser.waitForValue selector
    when 'enabled' then browser.waitForEnabled selector
  browser.pause 250
  return

waitForAlert = () ->
   i = 0
   while i < 25
    try
        browser.alertText()
        break;
    catch err
      i++;
      browser.pause 250
      continue;
 