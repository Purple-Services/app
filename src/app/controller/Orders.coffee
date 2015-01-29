 Ext.define 'Purple.controller.Orders'
  extend: 'Ext.app.Controller'
  requires: [
    'Purple.view.Order'
  ]
  config:
    refs:
      mainContainer: 'maincontainer'
      topToolbar: 'toptoolbar'
      ordersTabContainer: '#ordersTabContainer'
      orders: 'orders' # the Orders *page*
      ordersList: '[ctype=ordersList]'
      order: 'order'
    control:
      orders:
        viewOrder: 'viewOrder'
        loadOrdersList: 'loadOrdersList'
      order:
        backToOrders: 'backToOrders'

  # will be null until they log in
  orders: null

  launch: ->
    @callParent arguments

  getOrderById: (id) ->
    for o in @orders
      if o['id'] is orderId
        order = o
        break
    return order

  viewOrder: (orderId) ->
    @getOrdersTabContainer().setActiveItem(
      Ext.create 'Purple.view.Order',
        orderId: orderId
    )
    
    for o in @orders
      if o['id'] is orderId
        order = o
        break
    console.log order
    #@getOrder().setValues order

  backToOrders: ->
    @getOrdersTabContainer().remove(
      @getOrder(),
      yes
    )

  loadOrdersList: (forceUpdate = no, callback = null) ->
    if @orders? and not forceUpdate
      @renderOrdersList @orders
    else
      Ext.Viewport.setMasked
        xtype: 'loadmask'
        message: ''
      Ext.Ajax.request
        url: "#{util.WEB_SERVICE_BASE_URL}user/details"
        params: Ext.JSON.encode
          user_id: localStorage['purpleUserId']
          token: localStorage['purpleToken']
        headers:
          'Content-Type': 'application/json'
        timeout: 30000
        method: 'POST'
        scope: this
        success: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          if response.success
            @orders = response.orders
            util.ctl('Vehicles').vehicles = response.vehicles
            util.ctl('Vehicles').loadVehiclesList()
            @renderOrdersList @orders
            callback?()
          else
            navigator.notification.alert response.message, (->), "Error"
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          response = Ext.JSON.decode response_obj.responseText
          console.log response
  
  renderOrdersList: (orders) ->
    list =  @getOrdersList()
    if not list?
      return
    list.removeAll yes, yes
    for o in orders
      v = util.ctl('Vehicles').getVehicleById(o.vehicle_id)
      v ?=
        id: o.vehicle_id
        user_id: localStorage['purpleUserId']
        year: "Vehicle Deleted"
        timestamp_created: "1970-01-01T00:00:00Z"
        color: ""
        gas_type: ""
        license_plate: ""
        make: ""
        model: ""
      list.add
        xtype: 'textfield'
        id: "oid_#{o.id}"
        flex: 0
        label: """
          #{Ext.util.Format.date(
            new Date(o.target_time_start * 1000),
            "F jS"
          )}<br />
          #{v.year} #{v.make} #{v.model}
        """
        labelWidth: '100%'
        cls: [
          'bottom-margin'
        ]
        disabled: yes
        listeners:
          initialize: (field) =>
            field.element.on 'tap', =>
              oid = field.getId().split('_')[1]
              @viewOrder oid
