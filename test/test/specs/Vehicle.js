var Utils, assert, sinon;

Utils = require('./test_utils.js');

assert = require('assert');

sinon = require('sinon');

describe('webdriver.io page', function() {
  it('should create a new car', function() {
    this.timeout(30000);
    Utils.login("Vehicle");
    console.log('should create a new car');
    Utils.getMenu('div=Vehicles');
    console.log('go to vehicles');
    browser.click('span=Add Vehicle');
    browser.click('div=Year');
    browser.click('span=2016');
    console.log('year set to 2016');
    Utils.waitUntil('value', '[name="year"]');
    browser.click('div=Make');
    browser.click('span=Acura');
    console.log('make set to Acura');
    Utils.waitUntil('value', '[name="make"]');
    browser.click('div=Model');
    browser.click('span=MDX');
    console.log('Model set to MDX');
    Utils.waitUntil('value', '[name="model"]');
    browser.click('div=Color');
    browser.click('span=White');
    console.log('color set to white');
    Utils.waitUntil('value', '[name="color"]');
    browser.setValue('[name="license_plate"]', '1ABC234');
    console.log('license plate set');
    browser.click('span=Save Changes');
    Utils.waitUntil('visible', 'span=2016 Acura MDX');
  });
  it('should delete the newest car', function() {
    console.log('should delete the new car');
    Utils.getMenu('div=Vehicles');
    console.log('go to vehicles');
    Utils.getList('.vehicle-list-item');
    console.log('car clicked');
    browser.click('span=Delete Vehicle');
    Utils.waitForAlert(true);
    console.log('deleted');
    Utils.waitUntil('visible', 'span=Add Vehicle');
  });
});
