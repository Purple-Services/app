Ext.define("Purple.plugin.NonListPullRefresh", {
  extend: "Ext.Component",
  alias: "plugin.nonlistpullrefresh",
  requires: ["Ext.DateExtras"],
  config: {

    /*
    @cfg {Ext.dataview.List} list
    The list to which this PullRefresh plugin is connected.
    This will usually by set automatically when configuring the list with this plugin.
    @accessor
     */
    parentCmp: null,

    /*
    @cfg {String} pullRefreshText The text that will be shown while you are pulling down.
    @accessor
     */
    pullRefreshText: "Pull down to refresh...",

    /*
    @cfg {String} releaseRefreshText The text that will be shown after you have pulled down enough to show the release message.
    @accessor
     */
    releaseRefreshText: "Release to refresh...",

    /*
    @cfg {String} lastUpdatedText The text to be shown in front of the last updated time.
    @accessor
     */
    lastUpdatedText: "Last Updated:",

    /*
    @cfg {String} loadingText The text that will be shown while the list is refreshing.
    @accessor
     */
    loadingText: "Loading...",

    /*
    @cfg {Number} snappingAnimationDuration The duration for snapping back animation after the data has been refreshed
    @accessor
     */
    snappingAnimationDuration: 150,

    /*
    @cfg {Function} refreshFn The function that will be called to refresh the list.
    If this is not defined, the store's load function will be called.
    The refresh function gets called with a reference to this plugin instance.
    @accessor
     */
    refreshFn: null,

    /*
    @cfg {Ext.XTemplate/String/Array} pullTpl The template being used for the pull to refresh markup.
    @accessor
     */
    pullTpl: ["<div class=\"x-list-pullrefresh\">", "<div class=\"x-list-pullrefresh-arrow\"></div>", "<div class=\"x-loading-spinner\">", "<span class=\"x-loading-top\"></span>", "<span class=\"x-loading-right\"></span>", "<span class=\"x-loading-bottom\"></span>", "<span class=\"x-loading-left\"></span>", "</div>", "<div class=\"x-list-pullrefresh-wrap\">", "<h3 class=\"x-list-pullrefresh-message\">{message}</h3>", "<div class=\"x-list-pullrefresh-updated\">{lastUpdatedText}&nbsp;{lastUpdated:date(\"m/d/Y h:iA\")}</div>", "</div>", "</div>"].join(""),
    translatable: true
  },
  isRefreshing: false,
  currentViewState: "",
  initialize: function() {
    this.callParent();
    this.on({
      painted: "onPainted",
      scope: this
    });
    return true;
  },
  init: function(c) {
    var me;
    me = this;
    me.setParentCmp(c);
    me.initScrollable();
    return true;
  },
  initScrollable: function() {
    var c, element, me, pullTpl, scrollable, scroller, store;
    me = this;
    c = me.getParentCmp();
    store = null;
    pullTpl = me.config.pullTpl;
    element = me.element;
    scrollable = c.getScrollable();
    scroller = void 0;
    if (!scrollable) {
      return;
    }
    scroller = scrollable.getScroller();
    me.lastUpdated = new Date();
    c.insert(0, me);
    pullTpl.overwrite(element, {
      message: me.getPullRefreshText(),
      lastUpdatedText: me.getLastUpdatedText(),
      lastUpdated: me.lastUpdated
    }, true);
    me.loadingElement = element.getFirstChild();
    me.messageEl = element.down(".x-list-pullrefresh-message");
    me.updatedEl = element.down(".x-list-pullrefresh-updated");
    me.maxScroller = scroller.getMaxPosition();
    scroller.on({
      maxpositionchange: me.setMaxScroller,
      scroll: me.onScrollChange,
      scope: me
    });
    return true;
  },
  onScrollableChange: function() {
    this.initScrollable();
    return true;
  },
  updateList: function(newList, oldList) {
    var me;
    me = this;
    if (newList && newList !== oldList) {
      newList.on({
        order: "after",
        scrollablechange: me.onScrollableChange,
        scope: me
      });
    } else if (oldList) {
      oldList.un({
        order: "after",
        scrollablechange: me.onScrollableChange,
        scope: me
      });
    }
    return true;
  },

  /*
  @private
  Attempts to load the newest posts via the attached List's Store's Proxy
   */
  fetchLatest: function() {
    var operation, proxy, store;
    store = this.getParentCmp().getEventRecord().stores[0];
    proxy = store.getProxy();
    operation = void 0;
    operation = Ext.create("Ext.data.Operation", {
      page: 1,
      start: 0,
      model: store.getModel(),
      limit: store.getPageSize(),
      action: "read",
      filters: (store.getRemoteFilter() ? store.getFilters() : [])
    });
    proxy.read(operation, this.onLatestFetched, this);
    return true;
  },

  /*
  @private
  Called after fetchLatest has finished grabbing data. Matches any returned records against what is already in the
  Store. If there is an overlap, updates the existing records with the new data and inserts the new items at the
  front of the Store. If there is no overlap, insert the new records anyway and record that there's a break in the
  timeline between the new and the old records.
   */
  onLatestFetched: function(operation) {
    var i, length, newRecord, newRecords, oldRecord, oldRecords, store, toInsert;
    store = this.getParentCmp().getEventRecord().stores[0];
    oldRecords = store.getData();
    newRecords = operation.getRecords();
    length = newRecords.length;
    toInsert = [];
    newRecord = void 0;
    oldRecord = void 0;
    i = void 0;
    i = 0;
    while (i < length) {
      newRecord = newRecords[i];
      oldRecord = oldRecords.getByKey(newRecord.getId());
      if (oldRecord) {
        oldRecord.set(newRecord.getData());
      } else {
        toInsert.push(newRecord);
      }
      oldRecord = undefined;
      i++;
    }
    store.insert(0, toInsert);
    return true;
  },
  onPainted: function() {
    this.pullHeight = this.loadingElement.getHeight();
    return true;
  },
  setMaxScroller: function(scroller, position) {
    this.maxScroller = position;
    return true;
  },
  onScrollChange: function(scroller, x, y) {
    if (y < 0) {
      this.onBounceTop(y);
    }
    if (y > this.maxScroller.y) {
      this.onBounceBottom(y);
    }
    return true;
  },

  /*
  @private
   */
  applyPullTpl: function(config) {
    if (Ext.isObject(config) && config.isTemplate) {
      config;
    } else {
      new Ext.XTemplate(config);
    }
    return true;
  },
  onBounceTop: function(y) {
    var list, me, pullHeight, scroller;
    me = this;
    pullHeight = me.pullHeight;
    list = me.getParentCmp();
    scroller = list.getScrollable().getScroller();
    if (!me.isReleased) {
      if (!pullHeight) {
        me.onPainted();
        pullHeight = me.pullHeight;
      }
      if (!me.isRefreshing && -y >= pullHeight + 10) {
        me.isRefreshing = true;
        me.setViewState("release");
        scroller.getContainer().onBefore({
          dragend: "onScrollerDragEnd",
          single: true,
          scope: me
        });
      } else if (me.isRefreshing && -y < pullHeight + 10) {
        me.isRefreshing = false;
        me.setViewState("pull");
      }
    }
    me.getTranslatable().translate(0, -y);
    return true;
  },
  onScrollerDragEnd: function() {
    var list, me, scroller;
    me = this;
    if (me.isRefreshing) {
      list = me.getParentCmp();
      scroller = list.getScrollable().getScroller();
      scroller.minPosition.y = -me.pullHeight;
      scroller.on({
        scrollend: "loadStore",
        single: true,
        scope: me
      });
      me.isReleased = true;
    }
    return true;
  },
  loadStore: function() {
    this.setViewState('loading');
    this.isReleased = false;
    if (this.getRefreshFn != null) {
      this.getRefreshFn().call(this, this);
    } else {
      this.fetchLatest();
    }
    return true;
  },
  onBounceBottom: Ext.emptyFn,
  setViewState: function(state) {
    var loadingElement, me, messageEl, prefix;
    me = this;
    prefix = Ext.baseCSSPrefix;
    messageEl = me.messageEl;
    loadingElement = me.loadingElement;
    if (state === me.currentViewState) {
      return me;
    }
    me.currentViewState = state;
    if (messageEl && loadingElement) {
      switch (state) {
        case "pull":
          messageEl.setHtml(me.getPullRefreshText());
          loadingElement.removeCls([prefix + "list-pullrefresh-release", prefix + "list-pullrefresh-loading"]);
          break;
        case "release":
          messageEl.setHtml(me.getReleaseRefreshText());
          loadingElement.addCls(prefix + "list-pullrefresh-release");
          break;
        case "loading":
          messageEl.setHtml(me.getLoadingText());
          loadingElement.addCls(prefix + "list-pullrefresh-loading");
      }
    }
    return me;
  },
  resetRefreshState: function() {
    var me;
    me = this;
    me.isRefreshing = false;
    me.lastUpdated = new Date();
    me.setViewState("pull");
    return me.updatedEl.setHtml(this.getLastUpdatedText() + "&nbsp;" + Ext.util.Format.date(me.lastUpdated, "m/d/Y h:iA"));
  }
});
