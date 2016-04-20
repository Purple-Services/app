Ext.define 'Override.ux.Map',
  override: 'Ext.Map'
  initMap: ->
    map = @getMap()
    if !map
      gm = (window.google or {}).maps
      if !gm
        return null
      element = @mapContainer
      mapOptions = @getMapOptions()
      event = gm.event
      me = this
      #Remove the API Required div
      if element.dom.firstChild
        Ext.fly(element.dom.firstChild).destroy()
      if Ext.os.is.iPad
        Ext.merge { navigationControlOptions: style: gm.NavigationControlStyle.ZOOM_PAN }, mapOptions
      mapOptions.mapTypeId = mapOptions.mapTypeId or gm.MapTypeId.ROADMAP
      mapOptions.center = mapOptions.center or new (gm.LatLng)(37.381592, -122.135672)
      # Palo Alto
      if mapOptions.center and mapOptions.center.latitude and !Ext.isFunction(mapOptions.center.lat)
        mapOptions.center = new (gm.LatLng)(mapOptions.center.latitude, mapOptions.center.longitude)
      mapOptions.zoom = mapOptions.zoom or 12
      map = new (gm.Map)(element.dom, mapOptions)
      @setMap map
      event.addListener map, 'zoom_changed', Ext.bind(me.onZoomChange, me)
      event.addListener map, 'maptypeid_changed', Ext.bind(me.onTypeChange, me)
      event.addListener map, 'center_changed', Ext.bind(me.onCenterChange, me)
      event.addListenerOnce map, 'tilesloaded', Ext.bind(me.onTilesLoaded, me)
      event.addListener map, 'dragstart', Ext.bind(me.onDragStart, me)
      event.addListener map, 'idle', Ext.bind(me.onIdle, me)
      event.addListener map, 'bounds_changed', Ext.bind(me.onBoundChange, me)
      @addMapListeners()
    @getMap()
    
  onDragStart: ->
    @fireEvent 'dragstart'

  onBoundChange: ->
    @fireEvent 'boundchange'

  onIdle: ->
    @fireEvent 'idle'