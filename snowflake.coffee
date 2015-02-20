reqwest = require './node_modules/reqwest/reqwest.js'

class SnowflakeApi
  constructor: (@apiUrl, @transport = "websocket") ->
    @socket = new WebSocket(@apiUrl)
    @socket.onmessage = handleWebSocketApiCall
 
 
  websocketcallbacks = {}
  handleWebSocketApiCall = (data) ->
    response = JSON.parse data.data
    request = response.request
    callback = websocketcallbacks[request.NameSpace + request.MethodName];
    delete websocketcallbacks[request.NameSpace + request.MethodName];
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

  ajaxApiCall: (method, namespace, params) =>
    console.log "AJAX"
  
  apiCall: (method, namespace, params) ->
    console.log "CALLING " + @apiUrl
    console.log "METHOD " + method
    console.log "NAMESPACE " + namespace
    console.log "PARAMS " + JSON.stringify params
    if @transport is "ajax"
        @ajaxApiCall method, namespace, params
    if @transport is "websocket"
        @webSocketApiCall method, namespace, params
        

    
    
exports.SnowflakeApi = SnowflakeApi
exports.status = status
