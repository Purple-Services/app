var Utils, assert, sinon;

Utils = require('./test_utils.js');

assert = require('assert');

sinon = require('sinon');

describe('webdriver.io page', function() {
  return it('should delete the order', function() {
    this.timeout(30000);
    Utils.login("DeleteOrder");
    console.log('should delete the order');
    Utils.getMenu('div=Orders');
    Utils.getList('.order-list-item');
    console.log('order clicked');
    browser.pause(3000);
    browser.click('span=Cancel Order');
    Utils.waitForAlert(true);
    console.log('deleted');
    return Utils.waitUntil('visible', 'div=Orders');
  });
});
