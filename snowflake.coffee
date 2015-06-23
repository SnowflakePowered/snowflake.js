reqwest = require './node_modules/reqwest/reqwest'

if not String.prototype.startsWith
  Object.defineProperty String.prototype, 'startsWith',
    enumerable: false,
    configurable: false,
    writable: false,
    value: (searchString, position) ->
      position = position || 0
      this.lastIndexOf(searchString, position) is position

exports.SnowflakeEndpoint =
class SnowflakeEndpoint
  constructor: (@apiUrl) ->

    if @apiUrl.startsWith "ws"
      @transport = "websocket"
    else
      @transport = "ajax"
    if @transport is "websocket"
      @socket = new WebSocket(@apiUrl)
      @socket.onmessage = handleWebSocketApiCall

  websocketcallbacks = {}
  handleWebSocketApiCall = (data) ->
    response = JSON.parse data.data
    console.log response
    if response.type is "methodresponse"
      request = response.request
      callback = websocketcallbacks[request.NameSpace + request.MethodName]
      if callback
        callback.resolve(response)
        delete websocketcallbacks[request.NameSpace + request.MethodName]

  webSocketApiCall: (method, namespace, params) ->
    request =
        "method": method
        "namespace": namespace
        "params": params
    promise = Promise.defer()
    websocketcallbacks[request.namespace + request.method] = promise
    window.setTimeout =>
      if @socket.readyState is WebSocket.OPEN
        @socket.send(JSON.stringify request)
      else
        window.setTimeout arguments.callee, 25
    , 25
    promise.promise.then (response) ->
      response

  ajaxApiCall: (method, namespace, params) ->
    request =
        url: @apiUrl + "/" + namespace + "/" + method + "?post"
        method: "post"
        type: "json"
        data: JSON.stringify params
    Promise.resolve reqwest request

  apiCall: (method, namespace, params) ->
    if @transport is "ajax"
      return @ajaxApiCall method, namespace, params
    if @transport is "websocket"
      return @webSocketApiCall method, namespace, params

exports.Snowflake =
class Snowflake
  constructor: (@apiEndpoint) ->
    @Games = {}
    @Platforms = {}
    @Controllers = {}
    @_apiGame =
      __gameGetGameResults: (fileName, platformId) =>
        @apiEndpoint.apiCall "Game.GetGameResults", "@",
         'filename' : fileName,
         'platform' : platformId
      __gameGetGameInfo: (scrapeResultId, fileName, platformId) =>
        @apiEndpoint.apiCall "Game.GetGameInfo", "@",
         'resultid' : scrapeResultId,
         'filename' : fileName,
         'platform' : platformId
      __gameAddGameInfo: (gameInfo) =>
        @apiEndpoint.apiCall "Game.AddGameInfo", "@",
              'gameinfo' : JSON.stringify gameInfo
      __gameGetAllGamesSorted: =>
        @apiEndpoint.apiCall "Game.GetAllGamesSorted", "@", {}
      __gameGetAllGames: =>
        @apiEndpoint.apiCall "Game.GetAllGames", "@", {}
      __gameGetGamesByPlatform: (platformId) =>
        @apiEndpoint.apiCall "Game.GetGamesByPlatform", "@",
          'platform' : platformId
      __gameGetFlags: (emulatorId) =>
        @apiEndpoint.apiCall "Game.GetFlags", "@",
          'emulator' : emulatorId
      __gameGetFlagValue: (emulatorId, gameId, flagKey) =>
        @apiEndpoint.apiCall "Game.GetFlagValue", "@",
          'emulator' : emulatorId
          'id' : gameId
          'key' : flagKey
      __gameGetFlagValues: (emulatorId, gameId) =>
        @apiEndpoint.apiCall "Game.GetFlagValues", "@",
          'emulator': emulatorId
          'id': gameId
      __gameGetFlagDefaultValues: (emulatorId) =>
        @apiEndpoint.apiCall "Game.GetFlagDefaultValues", "@",
          'emulator' : emulatorId
      __gameGetFlagDefaultValue: (emulatorId, flagKey) =>
        @apiEndpoint.apiCall "Game.GetFlagDefaultValue", "@",
          'emulator' : emulatorId
          'key' : flagKey
      __gameSetFlagValue: (emulatorId, gameId, flagKey, flagValue) =>
        @apiEndpoint.apiCall "Game.SetFlagValue", "@",
          'emulator' : emulatorId
          'id' : gameId
          'key' : flagKey
          'value' : flagValue
      __gameSetFlagValues: (emulatorId, gameId, flagValues) =>
        @apiEndpoint.apiCall "Game.SetFlagValues", "@",
          'emulator' : emulatorId
          'id' : gameId
          'values' : JSON.stringify flagValues
      __gameSetFlagDefaultValue: (emulatorId, flagKey, flagValue) =>
        @apiEndpoint.apiCall "Game.SetFlagDefaultValue", "@",
          'emulator' : emulatorId
          'key' : flagKey
          'value' : flagValue
      __gameStartGame: (emulatorId, gameId) =>
        @apiEndpoint.apiCall "Game.StartGame", "@",
          'emulator' : emulatorId
          'id' : gameId
      __gameHaltRunningGames: =>
        @apiEndpoint.apiCall "Game.HaltRunningGames", "@", {}
    @_apiPlatform =
      __platformGetPlatforms: =>
        @apiEndpoint.apiCall "Platform.GetPlatforms", "@", {}
      __platformGetPreferences: (platformId) =>
        @apiEndpoint.apiCall "Platform.GetPreferences", "@",
          'platform' : platformId
      __platformSetPreference: (platformId, preferenceName, preferenceValue) =>
        @apiEndpoint.apiCall "Platform.SetPreference", "@",
          'platform' : platformId
          'preference' : preferenceName
          'value' : preferenceValue
    @_apiSystem =
      __systemGetAllPlugins: =>
        @apiEndpoint.apiCall "System.GetAllPlugins", "@", {}
      __systemGetEmulatorBridgesByPlatform: (platformId) =>
        @apiEndpoint.apiCall "System.GetEmulatorBridgesByPlatform", "@",
          'platform' : platformId
      __systemGetEmulatorBridges: =>
        @apiEndpoint.apiCall "System.GetEmulatorBridges", "@", {}
      __systemGetScrapers: =>
        @apiEndpoint.apiCall "System.GetScrapers", "@", {}
      __systemGetScrapersByPlatform: (platformId) =>
        @apiEndpoint.apiCall "System.GetScrapersByPlatform", "@",
          'platform' : platformId
      __systemGetAllAjaxMethods: =>
        @apiEndpoint.apiCall "System.GetAllAjaxMethods", "@", {}
      __systemShutdownCore: =>
        @apiEndpoint.apiCall "System.ShutdownCore", "@", {}
    @_apiController =
      __controllerGetProfiles: (controllerId) =>
        @apiEndpoint.apiCall "Controller.GetProfiles", "@",
          'controller' : controllerId
      __controllerGetProfileForDevice: (controllerId, deviceName) =>
        @apiEndpoint.apiCall "Controller.GetProfileForDevice", "@",
          'controller' : controllerId
          'device' : deviceName
      __controllerSetInputConfiguration: (controllerId, deviceName, inputConfig) =>
        @apiEndpoint.apiCall "Controller.SetInputConfiguration", "@",
          'controller' : controllerId
          'device' : deviceName
          'inputconfig': JSON.stringify inputConfig
      __controllerGetInputDevices: =>
        @apiEndpoint.apiCall "Controller.GetInputDevices", "@", {}
      __controllerSetDeviceInPort: (platformId, port, deviceName) =>
        @apiEndpoint.apiCall "Controller.SetDeviceInPort", "@",
          'platform' : platformId
          'port' : port
          'device' : deviceName
      __controllerGetDeviceInPort: (platformId, port) =>
        @apiEndpoint.apiCall "Controller.GetDeviceInPort", "@",
          'platform' : platformId
          'port' : port
      __controllerGetDeviceInPorts: (platformId) =>
        @apiEndpoint.apiCall "Controller.GetDeviceInPorts", "@",
          'platform' : platformId
      __controllerGetControllers: =>
        @apiEndpoint.apiCall "Controller.GetControllers", "@", {}
     if @apiEndpoint.socket
      @apiEndpoint.socket.onopen = ->
        window.dispatchEvent new Event 'snowflake-ok'
     else
      window.dispatchEvent new Event 'snowflake-ok'

  getGameResults: (fileName, platformId) ->
    @_apiGame.__gameGetGameResults fileName, platformId
    .then (response) ->
      response.payload
  getGameInfo: (scrapeResultId, fileName, platformId) ->
    @_apiGame.__gameGetGameInfo scrapeResultId, fileName, platformId
    .then (response) ->
      response.payload
  addGameInfo: (gameInfo) ->
    @_apiGame.__gameAddGameInfo gameInfo
    .then (response) ->
      response.payload
  getGames: ->
    @_apiGame.__gameGetAllGamesSorted()
    .then (response) =>
      @Games = response.payload
      response.payload
  getGamesByPlatform: (platform) ->
    @_apiGame.__gameGetGamesByPlatform platform
    .then (response) ->
      response.payload
  getEmulatorFlags: (emulator) ->
    @_apiGame.__gameGetFlags emulator
    .then (response) ->
      response.payload
  getFlagValues: (emulator, gameId) ->
    @_apiGame.__gameGetFlagValues emulator, gameId
    .then (response) ->
      response.payload
  setFlagValue: (emulator, gameId, flagName, flagValue) ->
    @_apiGame.__gameSetFlagValue emulator, gameId, flagName, flagValue
    .then (response) ->
      response.payload
  setFlagValues: (emulator, gameId, flagValues) ->
    @_apiGame.__gameSetFlagValues emulator, gameId, flagValues
    .then (response) ->
      response.payload
  getFlagDefaultValues: (emulator) ->
    @_apiGame.__gameGetFlagDefaultValues emulator
    .then (response) ->
      response.payload
  setFlagDefaultValue: (emulator, flagName, flagValue) ->
    @_apiGame.__gameSetFlagValues emulator, flagName, flagValue
    .then (response) ->
      response.payload
  startGame: (emulatorId, gameId) ->
    @_apiGame.__gameStartGame emulatorId, gameId
    .then (response) ->
      response.payload
  getPlatforms: ->
    @_apiPlatform.__platformGetPlatforms()
    .then (response) =>
      @Platforms = response.payload
      response.payload
  getPreferences: (platformId) ->
    @_apiPlatform.__platformGetPreferences platformId
    .then (response) ->
      response.payload
  setPreference: (platformId, preferenceName, preferenceValue) ->
    @_apiPlatform.__platformSetPreference platformId, preferenceName, preferenceValue
    .then (response) ->
      response.payload
  getAllPlugins: ->
    @_apiSystem.__systemGetAllPlugins()
    .then (response) ->
      response.payload
  getEmulatorBridges: ->
    @_apiSystem.__systemGetEmulatorBridges()
    .then (response) ->
      response.payload
  getEmulatorBridgesByPlatform: (platform) ->
    @_apiSystem.__systemGetEmulatorBridgesByPlatform platform
    .then (response) ->
      response.payload
  getScrapers: ->
    @_apiSystem.__systemGetScrapers()
    .then (response) ->
      response.payload
  getScrapersByPlatform: ->
    @_apiSystem.__systemGetScrapersByPlatform platform
    .then (response) ->
      response.payload
  getAjaxMethods: ->
    @_apiSystem.__systemGetAllAjaxMethods()
    .then (response) ->
      response.payload
  shutdownCore: ->
    @_apiSystem.__systemShutdownCore()
    .catch (err) ->
      'success': true
  getControllers: ->
    @_apiController.__controllerGetControllers()
    .then (response) =>
      @Controllers = response.payload
      response.payload
  getControllerProfiles: (controllerId) ->
    @_apiController.__controllerGetProfiles controllerId
    .then (response) ->
      response.payload
  getControllerProfileForDevice: (controllerId, deviceName) ->
    @_apiController.__controllerGetProfileForDevice controllerId, deviceName
    .then (response) ->
      response.payload
  setInputConfiguration: (controllerId, deviceName, inputConfig) ->
    @_apiController.__controllerSetInputConfiguration controllerId, deviceName, inputConfig
    .then (response) ->
      response.payload
  getInputDevices: ->
    @_apiController.__controllerGetInputDevices()
    .then (response) ->
      response.payload
  setDeviceInPort: (platformId, port, deviceName) ->
    @_apiController.__controllerSetDeviceInPort platformId, port, deviceName
    .then (response) ->
      response.payload
  getDeviceInPort: (platformId, port) ->
    @_apiController.__controllerGetDeviceInPort platformId, port
    .then (response) ->
      response.payload
  getDeviceInPorts: (platformId) ->
    @_apiController.__controllerGetDeviceInPorts platformId
    .then (response) ->
      response.payload
  getGamesArray: ->
    @getGames()
    .then (response) ->
      Array.prototype.concat.apply [],
      Object.keys(response).map (index, value) ->
        response[index]
  getPlatformsArray: ->
    @getPlatforms()
    .then (response) ->
      Object.keys(response).map (index, value) ->
        response[index]
  getControllersArray: ->
    @getControllers()
    .then (response) ->
      Object.keys(response).map (index, value) ->
        response[index]
