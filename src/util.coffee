# "LOCAL", "PROD", "DEV"
VERSION = "DEV"

# VERSION = (
#   if localStorage['purpleUserId'] is 'fb10203286525511954' or
#   localStorage['purpleUserId'] is '2UAPcnsqYqlIaKDWOiUN' or
#   localStorage['purpleUserId'] is 'lGYvXf9qcRdJHzhAAIbH' or
#   localStorage['purpleUserId'] is 'aQ9sHTpPW6saayrTfRqE' or
#   localStorage['purpleUserId'] is 'PqDXJ6ghTAVMlcvQpaTG' then 'LOCAL' else 'DEV'
# )

# window.onerror = (message, url, lineNumber) ->
#   ga_storage?._trackEvent 'general', 'App Error', (util.ctl('Main').deviceId ? 'device id not yet set')
#   return false # let the default handler run as well (yes this is inverse to the more logical 'true')

window.util =
  WEB_SERVICE_BASE_URL: switch VERSION
    when "LOCAL" then "http://192.168.0.8:3000/"
    when "PROD" then "http://purple.elasticbeanstalk.com/"
    when "DEV" then "http://purple-dev.elasticbeanstalk.com/"

  STRIPE_PUBLISHABLE_KEY: switch VERSION
    when "LOCAL" then 'pk_test_HMdwupxgr2PUwzdFPLsSMJoJ'
    when "PROD" then 'pk_live_r8bUlYTZSxsNzgtjVAIH7bcA'
    when "DEV" then 'pk_test_HMdwupxgr2PUwzdFPLsSMJoJ'

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
