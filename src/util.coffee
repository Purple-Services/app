LOCAL = no

# window.onerror = (message, url, lineNumber) ->
#   ga_storage?._trackEvent 'general', 'App Error', (util.ctl('Main').deviceId ? 'device id not yet set')
#   return false # let the default handler run as well (yes this is inverse to the more logical 'true')

window.util =
  WEB_SERVICE_BASE_URL: if LOCAL then "http://localhost:3000/" else "https://service.purple.com/"
  RESOURCES_BASE_URL: if LOCAL then "http://localhost/purple/resources/" else "https://purple-resources.s3.amazonaws.com/mobile/resources/"

  # returns the controller (just a convenience function)
  ctl: (controllerName) ->
    Purple.app.getController controllerName

  strToTitleCase: (str) ->
    str.replace /\w\S*/g, (word) ->
      word.charAt(0).toUpperCase() + word.substr(1).toLowerCase()
