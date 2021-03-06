Ext.define 'Purple.view.Orders',
  extend: 'Ext.Container'
  xtype: 'orders'
  requires: [
    'Ext.form.*'
    'Ext.field.*'
    'Ext.Button'
    'Ext.XTemplate'
  ]
  config:
    layout:
      type: 'hbox'
      pack: 'start'
      align: 'start'
    height: '100%'
    cls: [
      'request-form'
      'accent-bg'
      'slideable'
    ]
    scrollable:
      direction: 'vertical'
      directionLock: yes
      translatable:
        translationMethod: 'auto'
    plugins: [
      {
        xclass: 'Purple.plugin.NonListPullRefresh'
        pullRefreshText: 'pull down to refresh'
        releaseRefreshText: 'release to refresh'
        loadingText: 'loading orders...'
        pullTpl: new Ext.XTemplate("""
          <div class="x-list-pullrefresh">
            <div class="x-list-pullrefresh-wrap" style="width: {[Ext.Viewport.element.getWidth()]}px;">
              <img src="resources/images/center-map-icon.png" width="35" height="35" />
              <h3 class="x-list-pullrefresh-message" style="display:none">
                {message}
              </h3>
              <div class="x-list-pullrefresh-updated" style="display:none">
                last updated: <span>{lastUpdated:date("m/d/Y h:iA")}</span>
              </div>
            </div>
          </div>
          <div class='x-list-emptytext' style='display:none;'>
            {[(navigator.onLine ? 'no orders' : 'unable to connect to internet<br />pull down to refresh')]}
          </div>
        """)
        refreshFn: (plugin) ->
          refresher = ->
            list = plugin.getParentCmp() # not actually of type List
            scroller = list.getScrollable().getScroller()
            util.ctl('Orders').loadOrdersList yes, ->
              scroller.minPosition.y = 0
              scroller.scrollTo null, 0, true
              plugin.resetRefreshState()
          refresher()
          return false
      }
    ]
    listeners:
      initialize: ->
        @fireEvent 'loadOrdersList', no, null
    items: [
      {
        xtype: 'spacer'
        flex: 1
      }
      {
        xtype: 'container'
        flex: 0
        width: '85%'
        layout:
          type: 'vbox'
          pack: 'start'
          align: 'start'
        items: [
          {
            xtype: 'component'
            flex: 0
            cls: 'heading'
            html: 'Orders'
          }
          {
            xtype: 'component'
            flex: 0
            cls: [
              'horizontal-rule'
              'purple-rule'
            ]
          }
          {
            xtype: 'container'
            ctype: 'ordersList'
            width: '100%'
            flex: 0
            layout: 'vbox'
          }
        ]
      }
      {
        xtype: 'spacer'
        flex: 1
      }
    ]

 
