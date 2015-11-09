Ext.define('Purple.controller.Menu', {
  extend: 'Ext.app.Controller',
  config: {
    refs: {
      mainContainer: 'maincontainer',
      topToolbar: 'toptoolbar',
      feedbackButton: '[ctype=feedbackButton]',
      helpButton: '[ctype=helpButton]',
      inviteButton: '[ctype=inviteButton]',
      menuButton: '[ctype=menuButton]',
      requestGasTabContainer: '#requestGasTabContainer',
      accountTab: '#accountTab',
      accountTabContainer: '#accountTabContainer',
      loginForm: 'loginform',
      mapForm: 'mapform',
      map: '#gmap'
    },
    control: {
      helpButton: {
        helpButtonTap: 'helpButtonTap'
      },
      feedbackButton: {
        feedbackButtonTap: 'feedbackButtonTap'
      },
      inviteButton: {
        inviteButtonTap: 'inviteButtonTap'
      },
      topToolbar: {
        freeGasButtonTap: 'freeGasButtonTap',
        menuButtonTap: 'menuButtonTap'
      }
    }
  },
  backButtonStack: [],
  launch: function() {
    return this.callParent(arguments);
  },
  open: function() {
    return this.getMainContainer().openContainer();
  },
  close: function() {
    return this.getMainContainer().closeContainer();
  },
  isClosed: function() {
    return this.getMainContainer().isClosed();
  },
  lockMenu: function() {
    return this.getMainContainer().setSlideSelector(false);
  },
  unlockMenu: function() {
    return this.getMainContainer().setSlideSelector('slideable');
  },
  pushOntoBackButton: function(fn) {
    this.backButtonStack.push(fn);
    this.getMainContainer().addCls('makeMenuButtonBeBackButton');
    return this.lockMenu();
  },
  popOffBackButton: function() {
    (this.backButtonStack.pop())();
    if (this.backButtonStack.length === 0) {
      this.getMainContainer().removeCls('makeMenuButtonBeBackButton');
      return this.unlockMenu();
    }
  },
  popOffBackButtonWithoutAction: function() {
    this.backButtonStack.pop();
    if (this.backButtonStack.length === 0) {
      this.getMainContainer().removeCls('makeMenuButtonBeBackButton');
      return this.unlockMenu();
    }
  },
  clearBackButtonStack: function() {
    this.backButtonStack = [];
    this.getMainContainer().removeCls('makeMenuButtonBeBackButton');
    return this.unlockMenu();
  },
  menuButtonTap: function() {
    if (this.backButtonStack.length !== 0) {
      return this.popOffBackButton();
    } else {
      if (this.isClosed()) {
        return this.open();
      } else {
        return this.close();
      }
    }
  },
  freeGasButtonTap: function() {
    var ref;
    if (!(util.ctl('Account').isUserLoggedIn() && util.ctl('Account').isCompleteAccount())) {
      return this.getMainContainer().getItems().getAt(0).select(1, false, false);
    } else if (this.getCurrentIndex() === 7) {
      this.selectOption((ref = this.indexBeforeFreeGas) != null ? ref : 2);
      return this.popOffBackButtonWithoutAction();
    } else {
      this.indexBeforeFreeGas = this.getCurrentIndex();
      this.pushOntoBackButton((function(_this) {
        return function() {
          return _this.selectOption(_this.indexBeforeFreeGas);
        };
      })(this));
      return this.selectOption(7);
    }
  },
  helpButtonTap: function() {
    return this.selectOption(5);
  },
  feedbackButtonTap: function() {
    return this.selectOption(6);
  },
  getCurrentIndex: function() {
    return this.getMainContainer().getActiveItem().data.index;
  },
  selectOption: function(index) {
    return this.getMainContainer().getItems().getAt(0).select(index, false, false);
  },
  changeTitle: function(index, title) {
    return this.getMainContainer().getAt(0).getAt(2).getAt(index).setData({
      title: title
    });
  },
  showTitles: function(indicies) {
    var i, j, len, results;
    results = [];
    for (j = 0, len = indicies.length; j < len; j++) {
      i = indicies[j];
      results.push(this.getMainContainer().getAt(0).getAt(2).getAt(i).show());
    }
    return results;
  },
  hideTitles: function(indicies) {
    var i, j, len, results;
    results = [];
    for (j = 0, len = indicies.length; j < len; j++) {
      i = indicies[j];
      results.push(this.getMainContainer().getAt(0).getAt(2).getAt(i).hide());
    }
    return results;
  },
  adjustForAppLoginState: function() {
    if (util.ctl('Account').isUserLoggedIn()) {
      this.hideTitles([1]);
      if (util.ctl('Account').isCourier()) {
        this.hideTitles([0, 4, 7, 8]);
        this.showTitles([2, 3, 9]);
        if (localStorage['purpleCourierGallons87'] == null) {
          localStorage['purpleCourierGallons87'] = 0;
        }
        if (localStorage['purpleCourierGallons91'] == null) {
          localStorage['purpleCourierGallons91'] = 0;
        }
        if (util.ctl('Main').courierPingIntervalRef == null) {
          util.ctl('Main').initCourierPing();
        }
        Ext.get(document.getElementsByTagName('body')[0]).addCls('courier-app');
      } else {
        this.hideTitles([8, 9]);
        this.showTitles([2, 3, 4, 7]);
        Ext.get(document.getElementsByTagName('body')[0]).removeCls('courier-app');
      }
      return util.ctl('Account').populateAccountForm();
    } else {
      this.hideTitles([2, 3, 4, 7, 8, 9]);
      return this.showTitles([1]);
    }
  }
});
