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
      orderTimePlaced: '[ctype=orderTimePlaced]'
      orderTimeDeadline: '[ctype=orderTimeDeadline]'
      orderDisplayTime: '[ctype=orderDisplayTime]'
      orderVehicle: '[ctype=orderVehicle]'
      orderGasPrice: '[ctype=orderGasPrice]'
      orderGallons: '[ctype=orderGallons]'
      orderGasType: '[ctype=orderGasType]'
      orderHorizontalRuleAboveVehicle: '[ctype=orderHorizontalRuleAboveVehicle]'
      orderVehicleMake: '[ctype=orderVehicleMake]'
      orderVehicleModel: '[ctype=orderVehicleModel]'
      orderVehicleYear: '[ctype=orderVehicleYear]'
      orderVehicleColor: '[ctype=orderVehicleColor]'
      orderVehicleLicensePlate: '[ctype=orderVehicleLicensePlate]'
      orderVehiclePhoto: '[ctype=orderVehiclePhoto]'
      orderCustomerName: '[ctype=orderCustomerName]'
      orderCustomerPhone: '[ctype=orderCustomerPhone]'
      orderServiceFee: '[ctype=orderServiceFee]'
      orderTotalPrice: '[ctype=orderTotalPrice]'
      orderHorizontalRuleAboveCustomerInfo: '[ctype=orderHorizontalRuleAboveCustomerInfo]'
      orderRating: '[ctype=orderRating]'
      textRating: '[ctype=textRating]'
      sendRatingButtonContainer: '[ctype=sendRatingButtonContainer]'
      nextStatusButtonContainer: '[ctype=nextStatusButtonContainer]'
    control:
      orders:
        viewOrder: 'viewOrder'
        loadOrdersList: 'loadOrdersList'
      order:
        backToOrders: 'backToOrders'
        cancelOrder: 'askToCancelOrder'
        sendRating: 'sendRating'
        nextStatus: 'askToNextStatus'
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
    util.ctl('Menu').pushOntoBackButton =>
      @backToOrders()

    @getOrder().addCls "status-#{order['status']}"

    if order['status'] is 'complete'
      @getOrderRating().show()

    order['display_status'] = switch order['status']
      when 'unassigned' then 'Choosing a Courier'
      else order['status']

    order['time_order_placed'] = Ext.util.Format.date(
      new Date(order['target_time_start'] * 1000),
      "g:i a"
    )

    order['time_deadline'] = Ext.util.Format.date(
      new Date(order['target_time_end'] * 1000),
      "g:i a"
    )

    diffMinutes = Math.floor(
      (order['target_time_end'] - order['target_time_start']) / 60
    )
    if diffMinutes < 60
      order['display_time'] = "within #{diffMinutes} minutes"
    else
      diffHours = Math.round(
        diffMinutes / 60
      )
      order['display_time'] = "within #{diffHours} hour#{if diffHours is 1 then '' else 's'}"
        
    for v in util.ctl('Vehicles').vehicles
      if v['id'] is order['vehicle_id']
        order['vehicle'] = "#{v.year} #{v.make} #{v.model}"
        break

    if util.ctl('Account').isCourier()
      v = order['vehicle']
      order['gas_type'] = v['gas_type']
      order['vehicle_make'] = v['make']
      order['vehicle_model'] = v['model']
      order['vehicle_year'] = v['year']
      order['vehicle_color'] = v['color']
      order['vehicle_license_plate'] = v['license_plate']
      order['vehicle_photo'] = v['photo']

      c = order['customer']
      order['customer_name'] = c['name']
      order['customer_phone'] = c['phone_number']

    order['gas_price'] = util.centsToDollars order['gas_price']
    order['service_fee'] = util.centsToDollars order['service_fee']
    order['total_price'] = util.centsToDollars order['total_price']

    @getOrder().setValues order
    if order['special_instructions'] is ''
      @getOrderSpecialInstructionsLabel().hide()
      @getOrderSpecialInstructions().hide()
      @getOrderAddressStreet().removeCls 'bottom-margin'

    if util.ctl('Account').isCourier()
      @getOrderTimePlaced().hide()
      @getOrderDisplayTime().hide()
      @getOrderVehicle().hide()
      @getOrderGasPrice().hide()
      @getOrderServiceFee().hide()
      @getOrderTotalPrice().hide()
      @getOrderRating().hide()
      
      @getOrderTimeDeadline().show()
      @getOrderHorizontalRuleAboveVehicle().show()
      @getOrderVehicleMake().show()
      @getOrderVehicleModel().show()
      @getOrderVehicleYear().show()
      @getOrderVehicleColor().show()
      @getOrderVehicleLicensePlate().show()
      @getOrderHorizontalRuleAboveCustomerInfo().show()
      @getOrderCustomerName().show()
      @getOrderCustomerPhone().show()
      @getOrderGasType().show()

      switch order['status']
        when "accepted"
          @getNextStatusButtonContainer().getAt(0).setText "Start Route"
          @getNextStatusButtonContainer().show()
        when "enroute"
          @getNextStatusButtonContainer().getAt(0).setText "Begin Servicing"
          @getNextStatusButtonContainer().show()
        when "servicing"
          @getNextStatusButtonContainer().getAt(0).setText "Complete Order"
          @getNextStatusButtonContainer().show()
      
      @getOrderAddressStreet().addCls 'click-to-edit'
      @getOrderAddressStreet().element.on 'tap', =>
        # google maps
        window.location.href = "comgooglemaps://?daddr=#{order.lat},#{order.lng}&directionsmode=driving"
        # standard maps
        #window.location.href = "maps://?q=#{order.lat},#{order.lng}"

      @getOrderCustomerPhone().addCls 'click-to-edit'
      @getOrderCustomerPhone().element.on 'tap', =>
        window.location.href = "tel://#{order['customer_phone']}"

      if order["vehicle_photo"]? and order["vehicle_photo"] isnt ''
        @getOrderVehiclePhoto().show()
        @getOrderVehiclePhoto().element.dom.style.cssText = """
          background-color: transparent;
          background-size: cover;
          background-repeat: no-repeat;
          background-position: center;
          height: 300px;
          width: 100%;
          background-image: url('#{order["vehicle_photo"]}') !important;
        """
    

  backToOrders: ->
    @getOrdersTabContainer()?.remove(
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
          version: util.VERSION_NUMBER
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
      if util.ctl('Account').isCourier()
        v = o['vehicle']
      else
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
      o.status is 'assigned' or
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
        version: util.VERSION_NUMBER
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
        version: util.VERSION_NUMBER
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

  askToNextStatus: ->
    values = @getOrder().getValues()
    currentStatus = values['status']
    nextStatus = util.NEXT_STATUS_MAP[currentStatus]
    navigator.notification.confirm(
      "",
      ((index) => switch index
        when 1 then @nextStatus()
        else return
      ),
      "Are you sure you want to mark this order as #{nextStatus}? (cannot be undone)",
      ["Yes", "No"]
    )

  nextStatus: ->
    values = @getOrder().getValues()
    currentStatus = values['status']
    id = @getOrder().config.orderId
    Ext.Viewport.setMasked
      xtype: 'loadmask'
      message: ''
    Ext.Ajax.request
      url: "#{util.WEB_SERVICE_BASE_URL}orders/update-status-by-courier"
      params: Ext.JSON.encode
        version: util.VERSION_NUMBER
        user_id: localStorage['purpleUserId']
        token: localStorage['purpleToken']
        order_id: id
        status: util.NEXT_STATUS_MAP[currentStatus]
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
        navigator.notification.alert "Connection error. Please go back to Orders page and pull down to refresh. Do not press this button again until you have the updated status on the Orders page.", (->), "Error"