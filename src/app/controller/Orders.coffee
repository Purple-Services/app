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
      orderSpecialInstructionsLabel: '[ctype=orderSpecialInstructionsLabel]'
      orderSpecialInstructions: '[ctype=orderSpecialInstructions]'
      orderAddressStreet: '[ctype=orderAddressStreet]'
      orderRating: '[ctype=orderRating]'
      textRating: '[ctype=textRating]'
      sendRatingButtonContainer: '[ctype=sendRatingButtonContainer]'
    control:
      orders:
        viewOrder: 'viewOrder'
        loadOrdersList: 'loadOrdersList'
      order:
        backToOrders: 'backToOrders'
        cancelOrder: 'askToCancelOrder'
        sendRating: 'sendRating'
      orderRating:
        change: 'orderRatingChange'

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
    for o in @orders
      if o['id'] is orderId
        order = o
        break
        
    @getOrdersTabContainer().setActiveItem(
      Ext.create 'Purple.view.Order',
        orderId: orderId
        status: order['status']
    )

    @getOrder().addCls "status-#{order['status']}"

    if order['status'] is 'complete'
      @getOrderRating().show()

    order['status'] = switch order['status']
      when 'unassigned' then 'Choosing a Courier'
      else order['status']

    order['time_order_placed'] = Ext.util.Format.date(
      new Date(order['target_time_start'] * 1000),
      "g:i a"
    )

    diff = Math.floor(
      (order['target_time_end'] - order['target_time_start']) / (60 * 60)
    )
    order['display_time'] = switch diff
      when 1 then 'within 1 hour'
      when 3 then 'within 3 hours'
      else 'error calculating'

    for v in util.ctl('Vehicles').vehicles
      if v['id'] is order['vehicle_id']
        order['vehicle'] = "#{v.year} #{v.make} #{v.model}"
        break

    @getOrder().setValues order
    if order['special_instructions'] is ''
      @getOrderSpecialInstructionsLabel().hide()
      @getOrderSpecialInstructions().hide()
      @getOrderAddressStreet().removeCls 'bottom-margin'
    

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
      v ?= # if we don't have it in local memory then it must have been deleted
        id: o.vehicle_id
        user_id: localStorage['purpleUserId']
        year: "Vehicle Deleted"
        timestamp_created: "1970-01-01T00:00:00Z"
        color: ""
        gas_type: ""
        license_plate: ""
        make: ""
        model: ""
      cls = [
        'bottom-margin'
        'order-list-item'
      ]
      if o.status is 'unassigned' or
      o.status is 'accepted' or
      o.status is 'enroute' or
      o.status is 'servicing'
        cls.push 'highlighted'
      list.add
        xtype: 'textfield'
        id: "oid_#{o.id}"
        flex: 0
        label: """
          #{Ext.util.Format.date(
            new Date(o.target_time_start * 1000),
            "F jS"
          )}
          <br /><span class="subtext">#{v.year} #{v.make} #{v.model}</span>
          <span class="status-square"></span>
        """
        labelWidth: '100%'
        cls: cls
        disabled: yes
        listeners:
          painted: ((o)=>((field) =>
            # todo -this method will cause a slight flicker for cancelled orders
            field.addCls "status-#{o.status}"))(o)
          initialize: (field) =>
            field.element.on 'tap', =>
              oid = field.getId().split('_')[1]
              @viewOrder oid

  askToCancelOrder: (id) ->
    navigator.notification.confirm(
      "",
      ((index) => switch index
        when 1 then @cancelOrder id
        else return
      ),
      "Are you sure you want to cancel this order?",
      ["Yes", "No"]
    )

  cancelOrder: (id) ->
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}orders/cancel"
      params: Ext.JSON.encode
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        order_id: id
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
          @backToOrders()
          @renderOrdersList @orders
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        console.log response_obj
        navigator.notification.alert "Connection error. Please try again.", (->), "Error"

  orderRatingChange: (field, value) ->
    @getTextRating().show()
    @getSendRatingButtonContainer().show()

  sendRating: ->
    values = @getOrder().getValues()
    id = @getOrder().config.orderId
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}orders/rate"
      params: Ext.JSON.encode
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        order_id: id
        rating:
          number_rating: values['number_rating']
          text_rating: values['text_rating']
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
          @backToOrders()
          @renderOrdersList @orders
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        console.log response_obj
        navigator.notification.alert "Connection error. Please try again.", (->), "Error"
