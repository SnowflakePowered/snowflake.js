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
    reqwest request

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
    @_apiPlatform =
      __platformGetPlatforms: =>
          @apiEndpoint.apiCall "Platform.GetPlatforms", "@", {}
    @_apiSystem = 
      __systemGetAllPlugins: =>
          @apiEndpoint.apiCall "System.GetAllPlugins", "@", {}
      __systemGetEmulatorBridgesForPlatform: (platformId) =>
          @apiEndpoint.apiCall "System.GetEmulatorBridgesByPlatform", "@", 
            'platform' : platformId
      __systemGetEmulatorBridges: =>
          @apiEndpoint.apiCall "System.GetEmulatorBridges", "@", {}
      __systemGetScrapers: =>
          @apiEndpoint.apiCall "System.GetScrapers", "@", {}
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
  getPlatforms: ->
      @_apiPlatform.__platformGetPlatforms()
      .then (response) =>
          @Platforms = response.payload
          response.payload
  getGamesArray: ->
    Array.prototype.concat.apply [], 
    Object.keys(@Games).map (index, value) =>
       @Games[index]
  getPlatformsArray: ->
    Object.keys(@Platforms).map (index, value) =>
        @Platforms[index]
