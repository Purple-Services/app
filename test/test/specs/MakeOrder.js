var Utils, assert, sinon;

Utils = require('./test_utils.js');

assert = require('assert');

sinon = require('sinon');

describe('webdriver.io page', function() {
  it('should make an order', function() {
    var clock;
    this.timeout(30000);
    Utils.login("MakeOrder");
    browser.pause(250);
    console.log('should make an order');
    Utils.getMenu('div=Request Gas');
    console.log('request gas menu');
    Utils.waitUntil('visible', '#requestGasButton');
    Utils.waitUntil('enabled', '#requestGasButton');
    browser.click('#requestGasButton');
    console.log('request gas button');
    Utils.waitUntil('visible', '#sendRequestButtonContainer');
    Utils.waitUntil('enabled', '#sendRequestButtonContainer');
    clock = sinon.useFakeTimers(new Date(2016, 3, 29).getTime());
    console.log(new Date());
    browser.click('#sendRequestButtonContainer');
    clock.restore();
    console.log(new Date());
    Utils.waitUntil('visible', '#confirmOrderButtonContainer');
    clock = sinon.useFakeTimers(new Date(2016, 3, 29).getTime());
    console.log(new Date());
    console.log('review order button');
    browser.click('#confirmOrderButtonContainer');
    clock.restore();
    console.log(new Date());
    console.log('confirm order');
    clock.restore();
    console.log(new Date());
    Utils.waitForAlert(true);
    console.log('clicked alert');
  });
});
