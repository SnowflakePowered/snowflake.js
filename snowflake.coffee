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
