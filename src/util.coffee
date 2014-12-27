# "LOCAL", "PROD", "DEV"
VERSION = "LOCAL"

# window.onerror = (message, url, lineNumber) ->
#   ga_storage?._trackEvent 'general', 'App Error', (util.ctl('Main').deviceId ? 'device id not yet set')
#   return false # let the default handler run as well (yes this is inverse to the more logical 'true')

window.util =
  WEB_SERVICE_BASE_URL: switch VERSION
    when "LOCAL" then "http://192.168.1.124:3000/"
    when "PROD" then "https://service.purpleapp.com/"
    when "DEV" then "http://purple-dev.elasticbeanstalk.com/"

  # returns the controller (just a convenience function)
  ctl: (controllerName) ->
    Purple.app.getController controllerName

  strToTitleCase: (str) ->
    str.replace /\w\S*/g, (word) ->
      word.charAt(0).toUpperCase() + word.substr(1).toLowerCase()
