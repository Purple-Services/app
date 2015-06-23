Ext.define "Purple.plugin.NonListPullRefresh",
  extend: "Ext.Component"
  alias: "plugin.nonlistpullrefresh"
  requires: ["Ext.DateExtras"]
  config:
    
    ###
    @cfg {Ext.dataview.List} list
    The list to which this PullRefresh plugin is connected.
    This will usually by set automatically when configuring the list with this plugin.
    @accessor
    ###
    parentCmp: null
    
    ###
    @cfg {String} pullRefreshText The text that will be shown while you are pulling down.
    @accessor
    ###
    pullRefreshText: "Pull down to refresh..."
    
    ###
    @cfg {String} releaseRefreshText The text that will be shown after you have pulled down enough to show the release message.
    @accessor
    ###
    releaseRefreshText: "Release to refresh..."
    
    ###
    @cfg {String} lastUpdatedText The text to be shown in front of the last updated time.
    @accessor
    ###
    lastUpdatedText: "Last Updated:"
    
    ###
    @cfg {String} loadingText The text that will be shown while the list is refreshing.
    @accessor
    ###
    loadingText: "Loading..."
    
    ###
    @cfg {Number} snappingAnimationDuration The duration for snapping back animation after the data has been refreshed
    @accessor
    ###
    snappingAnimationDuration: 150
    
    ###
    @cfg {Function} refreshFn The function that will be called to refresh the list.
    If this is not defined, the store's load function will be called.
    The refresh function gets called with a reference to this plugin instance.
    @accessor
    ###
    refreshFn: null
    
    ###
    @cfg {Ext.XTemplate/String/Array} pullTpl The template being used for the pull to refresh markup.
    @accessor
    ###
    pullTpl: ["<div class=\"x-list-pullrefresh\">", "<div class=\"x-list-pullrefresh-arrow\"></div>", "<div class=\"x-loading-spinner\">", "<span class=\"x-loading-top\"></span>", "<span class=\"x-loading-right\"></span>", "<span class=\"x-loading-bottom\"></span>", "<span class=\"x-loading-left\"></span>", "</div>", "<div class=\"x-list-pullrefresh-wrap\">", "<h3 class=\"x-list-pullrefresh-message\">{message}</h3>", "<div class=\"x-list-pullrefresh-updated\">{lastUpdatedText}&nbsp;{lastUpdated:date(\"m/d/Y h:iA\")}</div>", "</div>", "</div>"].join("")
    translatable: true

  isRefreshing: false
  currentViewState: ""
  initialize: ->
    @callParent()
    @on
      painted: "onPainted"
      scope: this
    true


  init: (c) ->
    me = this
    me.setParentCmp c
    me.initScrollable()
    true

  initScrollable: ->
    me = this
    c = me.getParentCmp()
    store = null
    
    pullTpl = me.config.pullTpl
    element = me.element
    scrollable = c.getScrollable()
    scroller = undefined
    return  unless scrollable
    scroller = scrollable.getScroller()
    me.lastUpdated = new Date()
    c.insert 0, me

    pullTpl.overwrite element,
      message: me.getPullRefreshText()
      lastUpdatedText: me.getLastUpdatedText()
      lastUpdated: me.lastUpdated
    , true
    me.loadingElement = element.getFirstChild()
    me.messageEl = element.down(".x-list-pullrefresh-message")
    me.updatedEl = element.down(".x-list-pullrefresh-updated")
    me.maxScroller = scroller.getMaxPosition()
    scroller.on
      maxpositionchange: me.setMaxScroller
      scroll: me.onScrollChange
      scope: me
    true

  onScrollableChange: ->
    @initScrollable()
    true

  updateList: (newList, oldList) ->
    me = this
    if newList and newList isnt oldList
      newList.on
        order: "after"
        scrollablechange: me.onScrollableChange
        scope: me

    else if oldList
      oldList.un
        order: "after"
        scrollablechange: me.onScrollableChange
        scope: me
    true


  
  ###
  @private
  Attempts to load the newest posts via the attached List's Store's Proxy
  ###
  fetchLatest: ->
    store = @getParentCmp().getEventRecord().stores[0]
    proxy = store.getProxy()
    operation = undefined
    operation = Ext.create("Ext.data.Operation",
      page: 1
      start: 0
      model: store.getModel()
      limit: store.getPageSize()
      action: "read"
      filters: (if store.getRemoteFilter() then store.getFilters() else [])
    )
    proxy.read operation, @onLatestFetched, this
    true

  
  ###
  @private
  Called after fetchLatest has finished grabbing data. Matches any returned records against what is already in the
  Store. If there is an overlap, updates the existing records with the new data and inserts the new items at the
  front of the Store. If there is no overlap, insert the new records anyway and record that there's a break in the
  timeline between the new and the old records.
  ###
  onLatestFetched: (operation) ->
    store = @getParentCmp().getEventRecord().stores[0]
    oldRecords = store.getData()
    newRecords = operation.getRecords()
    length = newRecords.length
    toInsert = []
    newRecord = undefined
    oldRecord = undefined
    i = undefined
    i = 0
    while i < length
      newRecord = newRecords[i]
      oldRecord = oldRecords.getByKey(newRecord.getId())
      if oldRecord
        oldRecord.set newRecord.getData()
      else
        toInsert.push newRecord
      oldRecord = `undefined`
      i++
    store.insert 0, toInsert
    true

  onPainted: ->
    @pullHeight = @loadingElement.getHeight()
    true

  setMaxScroller: (scroller, position) ->
    @maxScroller = position
    true

  onScrollChange: (scroller, x, y) ->
    @onBounceTop y  if y < 0
    @onBounceBottom y  if y > @maxScroller.y
    true

  
  ###
  @private
  ###
  applyPullTpl: (config) ->
    (if (Ext.isObject(config) and config.isTemplate) then config else new Ext.XTemplate(config))
    true

  onBounceTop: (y) ->
    me = this
    pullHeight = me.pullHeight
    list = me.getParentCmp()
    scroller = list.getScrollable().getScroller()
    unless me.isReleased
      unless pullHeight
        me.onPainted()
        pullHeight = me.pullHeight
      if not me.isRefreshing and -y >= pullHeight + 10
        me.isRefreshing = true
        me.setViewState "release"
        scroller.getContainer().onBefore
          dragend: "onScrollerDragEnd"
          single: true
          scope: me

      else if me.isRefreshing and -y < pullHeight + 10
        me.isRefreshing = false
        me.setViewState "pull"
    me.getTranslatable().translate 0, -y
    true

  onScrollerDragEnd: ->
    me = this
    if me.isRefreshing
      list = me.getParentCmp()
      scroller = list.getScrollable().getScroller()
      scroller.minPosition.y = -me.pullHeight
      scroller.on
        scrollend: "loadStore"
        single: true
        scope: me

      me.isReleased = true
    true

  loadStore: ->
    #list = @getParentCmp()
    #store = list.getEventRecord().stores[0]
    # scroller = list.getScrollable().getScroller()
    @setViewState 'loading'
    @isReleased = false

    # store.on
    #   load: ->
    #     scroller.minPosition.y = 0
    #     scroller.scrollTo null, 0, true
    #     @resetRefreshState()
    #   delay: 100
    #   single: true
    #   scope: this
      
    if @getRefreshFn?
      @getRefreshFn().call this, this
    else
      @fetchLatest()
    
    return true

  onBounceBottom: Ext.emptyFn
  setViewState: (state) ->
    me = this
    prefix = Ext.baseCSSPrefix
    messageEl = me.messageEl
    loadingElement = me.loadingElement
    return me  if state is me.currentViewState
    me.currentViewState = state
    if messageEl and loadingElement
      switch state
        when "pull"
          messageEl.setHtml me.getPullRefreshText()
          loadingElement.removeCls [prefix + "list-pullrefresh-release", prefix + "list-pullrefresh-loading"]
        when "release"
          messageEl.setHtml me.getReleaseRefreshText()
          loadingElement.addCls prefix + "list-pullrefresh-release"
        when "loading"
          messageEl.setHtml me.getLoadingText()
          loadingElement.addCls prefix + "list-pullrefresh-loading"
    me

  resetRefreshState: ->
    me = this
    me.isRefreshing = false
    me.lastUpdated = new Date()
    me.setViewState "pull"
    me.updatedEl.setHtml @getLastUpdatedText() + "&nbsp;" + Ext.util.Format.date(me.lastUpdated, "m/d/Y h:iA")
