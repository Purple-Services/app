var Utils, assert, sinon;

Utils = require('./test_utils.js');

assert = require('assert');

sinon = require('sinon');

describe('webdriver.io page', function() {
  it('Gas Price at 90403', function() {
    browser.setGeoLocation({
      latitude: 34.027897,
      longitude: -118.499335,
      altitude: 200
    });
    browser.url(Utils.clientUrl);
    Utils.waitUntil('visible', '#requestGasButton');
    Utils.waitUntil('enabled', '#requestGasButton');
    assert.equal(browser.getText('#gas-price-display-87'), "$3.14");
    return assert.equal(browser.getText('#gas-price-display-91'), "$3.39");
  });
  it('Gas Price at 93063', function() {
    browser.setGeoLocation({
      latitude: 34.286097,
      longitude: -118.673906,
      altitude: 200
    });
    browser.url(Utils.clientUrl);
    Utils.waitUntil('visible', '#requestGasButton');
    Utils.waitUntil('enabled', '#requestGasButton');
    return assert.equal(browser.getText('#gas-price-unavailable'), "Location Outside Service Area");
  });
  it('Gas Price at 92007', function() {
    browser.setGeoLocation({
      latitude: 33.022104,
      longitude: -117.278696,
      altitude: 200
    });
    browser.url(Utils.clientUrl);
    Utils.waitUntil('visible', '#requestGasButton');
    Utils.waitUntil('enabled', '#requestGasButton');
    assert.equal(browser.getText('#gas-price-display-87'), "$3.00");
    return assert.equal(browser.getText('#gas-price-display-91'), "$3.16");
  });
  return it('Gas Price at 92109', function() {
    browser.setGeoLocation({
      latitude: 32.799097,
      longitude: -117.238433,
      altitude: 200
    });
    browser.url(Utils.clientUrl);
    Utils.waitUntil('visible', '#requestGasButton');
    Utils.waitUntil('enabled', '#requestGasButton');
    assert.equal(browser.getText('#gas-price-display-87'), "$3.00");
    return assert.equal(browser.getText('#gas-price-display-91'), "$3.16");
  });
});
