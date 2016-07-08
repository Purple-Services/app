Ext.define 'Purple.controller.Orders',
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
      orderAddressZipcode: '[ctype=orderAddressZipcode]'
      orderTirePressureCheck: '[ctype=orderTirePressureCheck]'
      orderTimePlaced: '[ctype=orderTimePlaced]'
      orderTimeDeadline: '[ctype=orderTimeDeadline]'
      orderDisplayTime: '[ctype=orderDisplayTime]'
      orderVehicle: '[ctype=orderVehicle]'
      orderLicensePlate: '[ctype=orderLicensePlate]'
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
      orderStatusDisplay: '[ctype=orderStatusDisplay]'
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

  orders: null
  orderListPageActive: yes

  launch: ->
    @callParent arguments

  getOrderById: (id) ->
    for o in @orders
      if o['id'] is orderId
        order = o
        break
    return order

  viewOrder: (orderId) ->
    @orderListPageActive = false
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
    @currentOrderClass = "status-#{order['status']}"

    if order['status'] is 'complete'
      @getOrderRating().show()

    order['display_status'] = if util.ctl('Account').isCourier()
      order['status']
    else
      switch order['status']
        when 'unassigned' then 'Accepted'
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
        order['license_plate'] = v.license_plate.toUpperCase()
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

    order['gas_price_display'] = util.centsToDollars order['gas_price']
    order['service_fee_display'] = util.centsToDollars order['service_fee']
    order['total_price_display'] = util.centsToDollars order['total_price']

    @getOrder().setValues order

    if order['tire_pressure_check']
      @getOrderTirePressureCheck().show()
    
    if order['special_instructions'] is ''
      @getOrderSpecialInstructionsLabel().hide()
      @getOrderSpecialInstructions().hide()
      @getOrderAddressStreet().removeCls 'bottom-margin'
    else 
      @getOrderSpecialInstructions().setHtml(order['special_instructions'])
      
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
      @getOrderAddressZipcode().show()

      switch order['status']
        when "unassigned"
          @getNextStatusButtonContainer().getAt(0).setText "Accept Order"
          @getNextStatusButtonContainer().show()
        when "assigned"
          @getNextStatusButtonContainer().getAt(0).setText "Accept Order"
          @getNextStatusButtonContainer().show()
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
        window.location.href = util.googleMapsDeepLink "?daddr=#{order.lat},#{order.lng}&directionsmode=driving"
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
    analytics?.page 'View Order',
      order_id: order.id

  backToOrders: ->
    @orderListPageActive = true
    @refreshOrdersAndOrdersList()
    @getOrdersTabContainer()?.remove(
      @getOrder(),
      yes
    )

  isUserBusy: ->
    util.ctl('Vehicles').getEditVehicleForm()? or
    util.ctl('Main').getRequestForm()? or
    util.ctl('Main').getRequestConfirmationForm()? or
    util.ctl('Account').getEditAccountForm()? or
    util.ctl('PaymentMethods').getEditPaymentMethodForm()? or
    @getOrder()?
  
  updateLastOrderCompleted: ->
    for order in @orders
      if order.status is 'complete'
        if localStorage['lastOrderCompleted']? and not @isUserBusy()
          if localStorage['lastOrderCompleted'] isnt order.id and localStorage['orderListLength'] is @orders.length.toString()
            if @getOrder()? then util.ctl('Menu').popOffBackButton()
            localStorage['lastOrderCompleted'] = order.id
            localStorage['orderListLength'] = @orders.length
            @sendToCompletedOrder()
        localStorage['lastOrderCompleted'] = order.id
        localStorage['orderListLength'] = @orders.length
        break

  sendToCompletedOrder: ->
    util.ctl('Menu').clearBackButtonStack()
    util.ctl('Main').getMainContainer().getItems().getAt(0).select 3, no, no
    @viewOrder localStorage['lastOrderCompleted']

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
          os: Ext.os.name # just an additional info
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
            @lastLoadOrdersList = new Date().getTime() / 1000
            @updateLastOrderCompleted()
          else
            navigator.notification.alert response.message, (->), "Error"
        failure: (response_obj) ->
          Ext.Viewport.setMasked false
          if util.ctl('Account').isCourier()
            navigator.notification.alert "Slow or no internet connection.", (->), "Error"
          response = Ext.JSON.decode response_obj.responseText
          console.log response

  isActiveOrder: (o) ->
    -1 isnt util.ACTIVE_STATUSES.indexOf o.status

  getActiveOrders: ->
    @orders.filter @isActiveOrder
  
  # only call this after orders have been loaded
  hasActiveOrder: ->
    @getActiveOrders().length > 0

  renderOrdersList: (orders) ->
    list =  @getOrdersList()
    if not list?
      return
    list.removeAll yes, yes
    if orders.length is 0 and not util.ctl('Account').isCourier()
      list.add
        xtype: 'component'
        flex: 0
        html: """
          No orders yet.
          <br />Let's change that! Get gas now.
        """
        cls: "loose-text"
        style: "text-align: center;"
      list.add
        xtype: 'container'
        # cls: 'slideable'
        flex: 0
        height: 110
        padding: '0 0 5 0'
        layout:
          type: 'vbox'
          pack: 'center'
          align: 'center'
        items: [
          {
            xtype: 'button'
            ui: 'action'
            cls: 'button-pop'
            text: 'Get Started'
            flex: 0
            disabled: no
            handler: ->
              util.ctl('Main').getMainContainer().getItems().getAt(0).select 0, no, no
          }
        ]
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
      if o.status is 'complete'
        cls.push 'highlighted'
      if util.ctl('Account').isCourier()
        isLate = o.status isnt "complete" and
          o.status isnt "cancelled" and
          (new Date(o.target_time_end * 1000)) < (new Date())
        dateDisplay = """
          <span style="#{if isLate then "color: #f00;" else ""}">
            #{Ext.util.Format.date(
              new Date(o.target_time_end * 1000),
              "n/j g:i a"
            )}
          </span>
        """
      else
        dateDisplay = Ext.util.Format.date(
          new Date(o.target_time_start * 1000),
          "F jS"
        )
      list.add
        xtype: 'textfield'
        id: "oid_#{o.id}"
        flex: 0
        label: """
          #{dateDisplay}
          <br /><span class="subtext">#{v.year} #{v.make} #{v.model}</span>
          <div class="status-square">
            <div class="fill">
              <svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="60px" height="60px" viewBox="0 0 60 60" enable-background="new 0 0 60 60" xml:space="preserve">
                <path fill="#04ACFF" id="waveShape" d="M300,300V2.5c0,0-0.6-0.1-1.1-0.1c0,0-25.5-2.3-40.5-2.4c-15,0-40.6,2.4-40.6,2.4
          c-12.3,1.1-30.3,1.8-31.9,1.9c-2-0.1-19.7-0.8-32-1.9c0,0-25.8-2.3-40.8-2.4c-15,0-40.8,2.4-40.8,2.4c-12.3,1.1-30.4,1.8-32,1.9
          c-2-0.1-20-0.8-32.2-1.9c0,0-3.1-0.3-8.1-0.7V300H300z"/>
              </svg>
            </div>
          </div>
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
              @refreshOrdersAndOrdersList()

  refreshOrdersAndOrdersList: ->
    currentTime = new Date().getTime() / 1000
    if currentTime - @lastLoadOrdersList > 30 or not @lastLoadOrdersList?
      if @orders? and @hasActiveOrder() and @getMainContainer().getActiveItem().data.index is 3 
        if @orderListPageActive
          @loadOrdersList yes
        else #order page is active
          @loadOrdersList yes, (Ext.bind @refreshOrder, this)

  refreshOrder: ->
    if @getOrder?()
      for o in @orders
        if o['id'] is @getOrder().config.orderId
          order = o
          break

      if order['status'] is 'unassigned' 
        @getOrderStatusDisplay().setValue 'Accepted'
      else 
        @getOrderStatusDisplay().setValue order['status']

      @getOrder().removeCls @currentOrderClass
      @getOrder().addCls "status-#{order['status']}"
      
      @currentOrderClass = "status-#{order['status']}"

      if order['status'] is 'complete'
        @getOrderRating().show()

  askToCancelOrder: (id) ->
    util.confirm(
      '',
      """
        Are you sure you want to cancel this order?
      """,
      (=> @cancelOrder id),
      null,
      'Yes',
      'No'
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
          util.ctl('Menu').popOffBackButtonWithoutAction()
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

  sendToAppStore: ->
    localStorage['sentUserToAppStore'] = 'yes'
    if Ext.os.is.iOS
      cordova.plugins.market.open "id970824802"
    else
      cordova.plugins.market.open "com.purple.app"

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
          util.ctl('Menu').popOffBackButtonWithoutAction()
          @renderOrdersList @orders
          if values['number_rating'] is 5 and localStorage['sentUserToAppStore'] isnt 'yes'
            util.confirm(
              "Do you have a few seconds to help us by rating the Purple app?",
              "Thanks!",
              @sendToAppStore,
              (=>
                if localStorage['sentUserToAppStore'] is 'attempted'
                  localStorage['sentUserToAppStore'] = 'yes'
                else
                  localStorage['sentUserToAppStore'] = 'attempted'
              )
            )
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
    util.confirm(
      '',
      (switch nextStatus
        when "assigned", "accepted"
          "Are you sure you want to accept this order? (cannot be undone)"
        else "Are you sure you want to mark this order as #{nextStatus}? (cannot be undone)"
      ),
      (Ext.bind @nextStatus, this)
      null,
      'Yes',
      'No'
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
          util.ctl('Menu').popOffBackButtonWithoutAction()
          @renderOrdersList @orders
        else
          navigator.notification.alert response.message, (->), "Error"
      failure: (response_obj) ->
        Ext.Viewport.setMasked false
        console.log response_obj
        navigator.notification.alert "Connection error. Please go back to Orders page and pull down to refresh. Do not press this button again until you have the updated status on the Orders page.", (->), "Error"
