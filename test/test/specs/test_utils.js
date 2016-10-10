var Utils;

Utils = function() {};

Utils.getMenu = function(divName) {
  var menus, returnMenu;
  browser.pause(500);
  menus = browser.elements('.menuButton');
  returnMenu = menus.value[menus.value.length - 1].ELEMENT;
  browser.elementIdClick(returnMenu);
  browser.pause(250);
  browser.click(divName);
  console.log('menu click');
  browser.pause(250);
};

Utils.hitBack = function() {
  var menus, returnMenu;
  browser.pause(500);
  menus = browser.elements('.menuButton');
  returnMenu = menus.value[menus.value.length - 1].ELEMENT;
  browser.elementIdClick(returnMenu);
  browser.pause(500);
};

Utils.getList = function(className) {
  var clickList, list;
  list = browser.elements(className);
  clickList = list.value[0].ELEMENT;
  browser.elementIdClick(clickList);
  console.log('list click');
  browser.pause(250);
};

Utils.waitUntil = function(func, selector, timeout) {
  if (!timeout) {
    timeout = 10000;
  }
  switch (func) {
    case 'visible':
      browser.waitForVisible(selector, timeout);
      break;
    case 'value':
      browser.waitForValue(selector, timeout);
      break;
    case 'enabled':
      browser.waitForEnabled(selector, timeout);
  }
  browser.pause(500);
};

Utils.waitForAlert = function(click) {
  var err, error, i;
  i = 0;
  while (i < 25) {
    try {
      browser.alertText();
      break;
    } catch (error) {
      err = error;
      i++;
      browser.pause(500);
      continue;
    }
  }
  console.log(browser.alertText());
  browser.pause(250);
  if (click === true) {
    browser.alertAccept();
    console.log('alert accepted');
  } else {
    browser.alertDismiss();
    console.log('alert dismissed');
  }
  return browser.pause(500);
};

Utils.login = function(name) {
  browser.url('file:////home/travis/build/Purple-Services/app/index-debug.html');
  console.log('should login for test ' + name);
  Utils.getMenu('div=Login');
  console.log('choose login');
  browser.setValue('.x-input-email', 'patrick@purpleapp.com');
  browser.setValue('.x-input-password', 'patrick');
  console.log('login info');
  browser.click('#loginButtonContainer');
  console.log('login');
  Utils.waitUntil('visible', '#requestGasButton');
};

module.exports = Utils;
