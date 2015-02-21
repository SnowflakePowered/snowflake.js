var SnowflakeApi, reqwest;

reqwest = require('./bower_components/reqwest/reqwest');

SnowflakeApi = (function() {
  var handleWebSocketApiCall, websocketcallbacks;

  function SnowflakeApi(apiUrl, transport) {
    this.apiUrl = apiUrl;
    this.transport = transport != null ? transport : "websocket";
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

  SnowflakeApi.prototype.webSocketApiCall = function(method, namespace, params) {
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

  SnowflakeApi.prototype.ajaxApiCall = function(method, namespace, params) {
    var getparams, key, request;
    getparams = (function() {
      var _i, _len, _ref, _results;
      _ref = Object.keys(params);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        _results.push({
          name: key,
          value: params[key]
        });
      }
      return _results;
    })();
    request = {
      url: this.apiUrl + "/" + namespace + "/" + method,
      method: "get",
      type: "json",
      data: getparams
    };
    console.log("PARAMS " + JSON.stringify(getparams));
    console.log("PARAMS " + JSON.stringify(params));
    return reqwest(request);
  };

  SnowflakeApi.prototype.apiCall = function(method, namespace, params) {
    console.log("CALLING " + this.apiUrl);
    console.log("METHOD " + method);
    console.log("NAMESPACE " + namespace);
    if (this.transport === "ajax") {
      return this.ajaxApiCall(method, namespace, params);
    }
    if (this.transport === "websocket") {
      return this.webSocketApiCall(method, namespace, params);
    }
  };

  return SnowflakeApi;

})();

exports.SnowflakeApi = SnowflakeApi;

exports.status = status;

//# sourceMappingURL=snowflake.js.map
