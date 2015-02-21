var SnowflakeEndpoint, reqwest;

reqwest = require('./node_modules/reqwest/reqwest');

exports.SnowflakeEndpoint = SnowflakeEndpoint = (function() {
  var handleWebSocketApiCall, websocketcallbacks;

  function SnowflakeEndpoint(apiUrl) {
    this.apiUrl = apiUrl;
    if (this.apiUrl.startsWith("ws")) {
      this.transport = "websocket";
    } else {
      this.transport = "ajax";
    }
    if (this.transport === "websocket") {
      this.socket = new WebSocket(this.apiUrl);
      this.socket.onmessage = handleWebSocketApiCall;
    }
  }

  websocketcallbacks = {};

  handleWebSocketApiCall = function(data) {
    var callback, request, response;
    response = JSON.parse(data.data);
    request = response.request;
    callback = websocketcallbacks[request.NameSpace + request.MethodName];
    delete websocketcallbacks[request.NameSpace + request.MethodName];
    return callback.resolve(response);
  };

  SnowflakeEndpoint.prototype.webSocketApiCall = function(method, namespace, params) {
    var promise, request;
    request = {
      "method": method,
      "namespace": namespace,
      "params": params
    };
    promise = Promise.defer();
    websocketcallbacks[request.namespace + request.method] = promise;
    this.socket.send(JSON.stringify(request));
    return promise.promise.then(function(response) {
      return response;
    });
  };

  SnowflakeEndpoint.prototype.ajaxApiCall = function(method, namespace, params) {
    var request;
    request = {
      url: this.apiUrl + "/" + namespace + "/" + method + "?post",
      method: "post",
      type: "json",
      data: JSON.stringify(params)
    };
    return reqwest(request);
  };

  SnowflakeEndpoint.prototype.apiCall = function(method, namespace, params) {
    if (this.transport === "ajax") {
      return this.ajaxApiCall(method, namespace, params);
    }
    if (this.transport === "websocket") {
      return this.webSocketApiCall(method, namespace, params);
    }
  };

  return SnowflakeEndpoint;

})();

//# sourceMappingURL=snowflake.js.map
