var Snowflake, SnowflakeEndpoint, reqwest;

reqwest = require('./node_modules/reqwest/reqwest');

if (!String.prototype.startsWith) {
  Object.defineProperty(String.prototype, 'startsWith', {
    enumerable: false,
    configurable: false,
    writable: false,
    value: function(searchString, position) {
      position = position || 0;
      return this.lastIndexOf(searchString, position) === position;
    }
  });
}

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

exports.Snowflake = Snowflake = (function() {
  function Snowflake(apiEndpoint) {
    this.apiEndpoint = apiEndpoint;
    this.Games = {};
    this.Platforms = {};
    this._apiGame = {
      __gameGetAllGamesSorted: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("Game.GetAllGamesSorted", "@", {});
        };
      })(this),
      __gameGetAllGames: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("Game.GetAllGames", "@", {});
        };
      })(this),
      __gameGetGamesByPlatform: (function(_this) {
        return function(platformId) {
          return _this.apiEndpoint.apiCall("Game.GetGamesByPlatform", "@", {
            'platform': platformId
          });
        };
      })(this),
      __gameGetFlags: (function(_this) {
        return function(emulatorId) {
          return _this.apiEndpoint.apiCall("Game.GetFlags", "@", {
            'emulator': emulatorId
          });
        };
      })(this),
      __gameGetFlagValue: (function(_this) {
        return function(emulatorId, gameId, flagKey) {
          return _this.apiEndpoint.apiCall("Game.GetFlagValue", "@", {
            'emulator': emulatorId,
            'id': gameId,
            'key': flagKey
          });
        };
      })(this),
      __gameGetFlagValues: (function(_this) {
        return function(emulatorId, gameId) {
          return _this.apiEndpoint.apiCall("Game.GetFlagValues", "@", {
            'emulator': emulatorId,
            'id': gameId
          });
        };
      })(this),
      __gameGetFlagDefaultValues: (function(_this) {
        return function(emulatorId) {
          return _this.apiEndpoint.apiCall("Game.GetFlagDefaultValues", "@", {
            'emulator': emulatorId
          });
        };
      })(this),
      __gameGetFlagDefaultValue: (function(_this) {
        return function(emulatorId, flagKey) {
          return _this.apiEndpoint.apiCall("Game.GetFlagDefaultValue", "@", {
            'emulator': emulatorId,
            'key': flagKey
          });
        };
      })(this),
      __gameSetFlagValue: (function(_this) {
        return function(emulatorId, gameId, flagKey, flagValue) {
          return _this.apiEndpoint.apiCall("Game.SetFlagValue", "@", {
            'emulator': emulatorId,
            'id': gameId,
            'key': flagKey,
            'value': flagValue
          });
        };
      })(this),
      __gameSetFlagDefaultValue: (function(_this) {
        return function(emulatorId, flagKey, flagValue) {
          return _this.apiEndpoint.apiCall("Game.SetFlagDefaultValue", "@", {
            'emulator': emulatorId,
            'key': flagKey,
            'value': flagValue
          });
        };
      })(this),
      __gameStartGame: (function(_this) {
        return function(emulatorId, gameId) {
          return _this.apiEndpoint.apiCall("Game.StartGame", "@", {
            'emulator': emulatorId,
            'id': gameId
          });
        };
      })(this),
      __gameHaltRunningGames: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("Game.HaltRunningGames", "@", {});
        };
      })(this),
      __gameSearchGames: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("Game.SearchGames", "@", {});
        };
      })(this)
    };
    this._apiPlatform = {
      __platformGetPlatforms: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("Platform.GetPlatforms", "@", {});
        };
      })(this),
      __platformGetPreferences: (function(_this) {
        return function(platformId) {
          return _this.apiEndpoint.apiCall("Platform.GetPreferences", "@", {
            'platform': platformId
          });
        };
      })(this),
      __platformSetPreference: (function(_this) {
        return function(platformId, preferenceName, preferenceValue) {
          return _this.apiEndpoint.apiCall("Platform.SetPreference", "@", {
            'platform': platformId,
            'preference': preferenceName,
            'value': preferenceValue
          });
        };
      })(this)
    };
    this._apiSystem = {
      __systemGetAllPlugins: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("System.GetAllPlugins", "@", {});
        };
      })(this),
      __systemGetEmulatorBridgesForPlatform: (function(_this) {
        return function(platformId) {
          return _this.apiEndpoint.apiCall("System.GetEmulatorBridgesByPlatform", "@", {
            'platform': platformId
          });
        };
      })(this),
      __systemGetEmulatorBridges: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("System.GetEmulatorBridges", "@", {});
        };
      })(this),
      __systemGetScrapers: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("System.GetScrapers", "@", {});
        };
      })(this)
    };
    ({
      __systemGetAllAjaxMethods: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("System.GetAllAjaxMethods", "@", {});
        };
      })(this),
      __systemShutdownCore: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("System.ShutdownCore", "@", {});
        };
      })(this)
    });
  }

  Snowflake.prototype.getGames = function() {
    return this._apiGame.__gameGetAllGamesSorted().then((function(_this) {
      return function(response) {
        _this.Games = response.payload;
        return response.payload;
      };
    })(this));
  };

  Snowflake.prototype.getGamesByPlatform = function(platform) {
    return this._apiGame.__gameGetGamesByPlatform(platform).then((function(_this) {
      return function(response) {
        return response.payload;
      };
    })(this));
  };

  Snowflake.prototype.getPlatforms = function() {
    return this._apiPlatform.__platformGetPlatforms().then((function(_this) {
      return function(response) {
        _this.Platforms = response.payload;
        return response.payload;
      };
    })(this));
  };

  Snowflake.prototype.getGamesArray = function() {
    return this.getGames().then((function(_this) {
      return function() {
        return Array.prototype.concat.apply([], Object.keys(_this.Games).map(function(index, value) {
          return _this.Games[index];
        }));
      };
    })(this));
  };

  Snowflake.prototype.getPlatformsArray = function() {
    return this.getPlatforms().then((function(_this) {
      return function() {
        return Object.keys(_this.Platforms).map(function(index, value) {
          return _this.Platforms[index];
        });
      };
    })(this));
  };

  return Snowflake;

})();

//# sourceMappingURL=snowflake.js.map
