# "LOCAL", "PROD", "DEV"
VERSION = "LOCAL"

# window.onerror = (message, url, lineNumber) ->
#   ga_storage?._trackEvent 'general', 'App Error', (util.ctl('Main').deviceId ? 'device id not yet set')
#   return false # let the default handler run as well (yes this is inverse to the more logical 'true')

window.util =
  WEB_SERVICE_BASE_URL: switch VERSION
    when "LOCAL" then "http://192.168.0.3:3000/"
    when "PROD" then "https://service.purpleapp.com/"
    when "DEV" then "http://purple-dev.elasticbeanstalk.com/"

  STRIPE_PUBLISHABLE_KEY: 'pk_test_HMdwupxgr2PUwzdFPLsSMJoJ'

  # returns the controller (just a convenience function)
  ctl: (controllerName) ->
    Purple.app.getController controllerName

  # show a component for a specified amount of time (t, millis), then hide it
  flashComponent: (c, t = 5000) ->
    c.show()
    setTimeout (=> c.hide()), t
