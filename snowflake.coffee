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
      delete websocketcallbacks[request.NameSpace + request.MethodName]
      callback.resolve(response)

  webSocketApiCall: (method, namespace, params) ->
    request =
        "method": method
        "namespace": namespace
        "params": params
    promise = Promise.defer()
    websocketcallbacks[request.namespace + request.method] = promise
    @socket.send(JSON.stringify request)
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
    
    @_apiGame =
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
      __gameSearchGames: =>
          @apiEndpoint.apiCall "Game.SearchGames", "@", {}
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
  getGames: ->
      @_apiGame.__gameGetAllGamesSorted()
      .then (response) =>
          @Games = response.payload
          response.payload
  getGamesByPlatform: (platform) ->
      @_apiGame.__gameGetGamesByPlatform platform 
      .then (response) =>
          response.payload
  getEmulatorFlags: (emulator) ->
      @_apiGame.__gameGetFlags emulator
      .then (response) =>
          response.payload
  getFlagValues: (emulator, gameId) ->
      @_apiGame.__gameGetFlagValues emulator, gameId
      .then (response) =>
          response.payload
  setFlagValue: (emulator, gameId, flagName, flagValue) ->
      @_apiGame.__gameSetFlagValues emulator, gameId, flagName, flagValue
      .then (response) =>
          response.payload
  getFlagDefaultValues: (emulator) ->
      @_apiGame.__gameGetFlagDefaultValues emulator
      .then (response) =>
          response.payload
  setFlagDefaultValue: (emulator, flagName, flagValue) ->
      @_apiGame.__gameSetFlagValues emulator, flagName, flagValue
      .then (response) =>
          response.payload
  startGame: (emulator, gameId) ->
      @_apiGame.__gameStartGame emulatorId, gameId
      .then (response) =>
          response.payload
  getPlatforms: ->
      @_apiPlatform.__platformGetPlatforms()
      .then (response) =>
          @Platforms = response.payload
          response.payload
  getAllPlugins: ->
  getEmulatorBridges: ->
  getEmulatorBridgesByPlatform: ->
  getScrapers: ->
  getScrapersByPlatform: ->
  getAjaxMethods: ->
  
  shutdownCore: ->
  
  getGamesArray: ->
    @getGames()
    .then =>
      Array.prototype.concat.apply [], 
      Object.keys(@Games).map (index, value) =>
         @Games[index]
  getPlatformsArray: ->
    @getPlatforms()
    .then =>
      Object.keys(@Platforms).map (index, value) =>
          @Platforms[index]
          
