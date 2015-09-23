# "LOCAL", "PROD", "DEV"
VERSION = "DEV"

if VERSION is "LOCAL" or VERSION is "DEV"
  window.onerror = (message, url, lineNumber) ->
    alert "#{message} #{lineNumber}"
    return false
else
  window.onerror = (message, url, lineNumber) ->
    ga_storage?._trackEvent 'error', 'App Error', "#{message} #{lineNumber}"
    return false # let the default handler run as well (yes this is inverse to the more logical 'true')

window.util =
  VERSION_NUMBER: "1.0.7"
  
  WEB_SERVICE_BASE_URL: switch VERSION
    when "LOCAL" then "http://localhost:3000/"
    when "PROD" then "https://purpledelivery.com/"
    when "DEV" then "http://purple-dev.elasticbeanstalk.com/"

  STRIPE_PUBLISHABLE_KEY: switch VERSION
    when "LOCAL" then 'pk_test_HMdwupxgr2PUwzdFPLsSMJoJ'
    when "PROD" then 'pk_live_r8bUlYTZSxsNzgtjVAIH7bcA'
    when "DEV" then 'pk_test_HMdwupxgr2PUwzdFPLsSMJoJ'

  GCM_SENDER_ID: "254423398507"  

  MINIMUM_GALLONS: 10
  GALLONS_INCREMENT: 5
  GALLONS_PER_TANK: 5

  STATUSES: [
    "unassigned"
    "assigned"
    "enroute"
    "servicing"
    "complete"
    "cancelled"
  ]

  NEXT_STATUS_MAP:
    "unassigned": "assigned"
    "assigned": "accepted"
    "accepted": "enroute"
    "enroute": "servicing"
    "servicing": "complete"
    "complete": "complete"
    "cancelled": "cancelled"

  # you can cancel your order if its status is below
  # (this is just frontend logic, there is a hard constraint in backend)
  CANCELLABLE_STATUSES: [
    "unassigned"
    "assigned"
    "accepted"
    "enroute"
  ]

  # returns the controller (just a convenience function)
  ctl: (controllerName) ->
    Purple.app.getController controllerName

  # show a component for a specified amount of time (t, millis), then hide it
  flashComponent: (c, t = 5000) ->
    c.show()
    setTimeout (=> c.hide()), t

  centsToDollars: (x) ->
    (x / 100).toFixed 2
