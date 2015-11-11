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
      event.addListener map, 'idle', Ext.bind(me.onIdle, me)
      @addMapListeners()
    @getMap()
    
  onIdle: ->
    mapOptions = @getMapOptions()
    map = @getMap()
    center = undefined
    center = if map and map.getCenter then map.getCenter() else mapOptions.center
    @options = Ext.apply(mapOptions, center: center)
    @fireEvent 'idle', this, map, center