Ext.define('Purple.view.Orders', {
  extend: 'Ext.Container',
  xtype: 'orders',
  requires: ['Ext.form.*', 'Ext.field.*', 'Ext.Button', 'Ext.XTemplate'],
  config: {
    layout: {
      type: 'hbox',
      pack: 'start',
      align: 'start'
    },
    height: '100%',
    cls: ['request-form', 'accent-bg', 'slideable'],
    scrollable: {
      direction: 'vertical',
      directionLock: true,
      translatable: {
        translationMethod: 'auto'
      }
    },
    plugins: [
      {
        xclass: 'Purple.plugin.NonListPullRefresh',
        pullRefreshText: 'pull down to refresh',
        releaseRefreshText: 'release to refresh',
        loadingText: 'loading orders...',
        pullTpl: new Ext.XTemplate("<div class=\"x-list-pullrefresh\">\n  <div class=\"x-list-pullrefresh-wrap\" style=\"width: {[Ext.Viewport.element.getWidth()]}px;\">\n    <img src=\"resources/images/center-map-icon.png\" width=\"35\" height=\"35\" />\n    <h3 class=\"x-list-pullrefresh-message\" style=\"display:none\">\n      {message}\n    </h3>\n    <div class=\"x-list-pullrefresh-updated\" style=\"display:none\">\n      last updated: <span>{lastUpdated:date(\"m/d/Y h:iA\")}</span>\n    </div>\n  </div>\n</div>\n<div class='x-list-emptytext' style='display:none;'>\n  {[(navigator.onLine ? 'no orders' : 'unable to connect to internet<br />pull down to refresh')]}\n</div>"),
        refreshFn: function(plugin) {
          var refresher;
          refresher = function() {
            var list, scroller;
            list = plugin.getParentCmp();
            scroller = list.getScrollable().getScroller();
            return util.ctl('Orders').loadOrdersList(true, function() {
              scroller.minPosition.y = 0;
              scroller.scrollTo(null, 0, true);
              return plugin.resetRefreshState();
            });
          };
          refresher();
          return false;
        }
      }
    ],
    listeners: {
      initialize: function() {
        return this.fireEvent('loadOrdersList', false, null);
      }
    },
    items: [
      {
        xtype: 'spacer',
        flex: 1
      }, {
        xtype: 'container',
        flex: 0,
        width: '85%',
        layout: {
          type: 'vbox',
          pack: 'start',
          align: 'start'
        },
        items: [
          {
            xtype: 'component',
            flex: 0,
            cls: 'heading',
            html: 'Orders'
          }, {
            xtype: 'component',
            flex: 0,
            cls: 'horizontal-rule'
          }, {
            xtype: 'container',
            ctype: 'ordersList',
            width: '100%',
            flex: 0,
            layout: 'vbox'
          }
        ]
      }, {
        xtype: 'spacer',
        flex: 1
      }
    ]
  }
});
