reqwest = require './bower_components/reqwest/reqwest'

class SnowflakeApi
  constructor: (@apiUrl, @transport = "websocket") ->
    
    if @transport is "websocket"
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

  ajaxApiCall: (method, namespace, params) ->
    getparams = ({ name: key, value: params[key]} for key in Object.keys(params))
    request = 
        url: @apiUrl + "/" + namespace + "/" + method 
        method: "get"
        type: "json"
        data: getparams
    console.log "PARAMS " + JSON.stringify getparams
    console.log "PARAMS " + JSON.stringify params

    reqwest request 
  
  apiCall: (method, namespace, params) ->
    console.log "CALLING " + @apiUrl
    console.log "METHOD " + method
    console.log "NAMESPACE " + namespace
    if @transport is "ajax"
        return @ajaxApiCall method, namespace, params
    if @transport is "websocket"
        return @webSocketApiCall method, namespace, params
        
    
exports.SnowflakeApi = SnowflakeApi
exports.status = status
