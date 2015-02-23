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
    console.log(response);
    if (response.type === "methodresponse") {
      request = response.request;
      callback = websocketcallbacks[request.NameSpace + request.MethodName];
      delete websocketcallbacks[request.NameSpace + request.MethodName];
      return callback.resolve(response);
    }
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
    return Promise.resolve(reqwest(request));
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
    this.Controllers = {};
    this._apiGame = {
      __gameGetGameResults: (function(_this) {
        return function(fileName, platformId) {
          return _this.apiEndpoint.apiCall("Game.GetGameResults", "@", {
            'filename': fileName,
            'platform': platformId
          });
        };
      })(this),
      __gameGetGameInfo: (function(_this) {
        return function(scrapeResultId, fileName, platformId) {
          return _this.apiEndpoint.apiCall("Game.GetGameInfo", "@", {
            'resultid': scrapeResultId,
            'filename': fileName,
            'platform': platformId
          });
        };
      })(this),
      __gameAddGameInfo: (function(_this) {
        return function(gameInfo) {
          return _this.apiEndpoint.apiCall("Game.AddGameInfo", "@", {
            'gameinfo': gameInfo
          });
        };
      })(this),
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
      __systemGetEmulatorBridgesByPlatform: (function(_this) {
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
      })(this),
      __systemGetScrapersByPlatform: (function(_this) {
        return function(platformId) {
          return _this.apiEndpoint.apiCall("System.GetScrapersByPlatform", "@", {
            'platform': platformId
          });
        };
      })(this),
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
    };
    this._apiController = {
      __controllerGetProfiles: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("Controller.GetProfiles", "@", {});
        };
      })(this),
      __controllerSetInput: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("Controller.SetInput", "@", {});
        };
      })(this),
      __controllerGetInputDevices: (function(_this) {
        return function(controllerProfile) {
          return _this.apiEndpoint.apiCall("Controller.GetInputDevices", "@", {});
        };
      })(this),
      __controllerSetInputDevice: (function(_this) {
        return function(controllerProfile, slot) {
          return _this.apiEndpoint.apiCall("Controller.SetInputDevice", "@", {});
        };
      })(this),
      __controllerGetControllers: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("Controller.GetControllers", "@", {});
        };
      })(this),
      __controllerLoadFileProfile: (function(_this) {
        return function() {
          return _this.apiEndpoint.apiCall("Controller.LoadFileProfile", "@", {});
        };
      })(this)
    };
  }

  Snowflake.prototype.getGameResults = function(fileName, platformId) {
    return this._apiGame.__gameGetGameResults(fileName, platformId).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getGameInfo = function(scrapeResultId, fileName, platformId) {
    return this._apiGame.__gameGetGameInfo(scrapeResultId, fileName, platformId).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.addGameInfo = function(gameInfo) {
    return this._apiGame.__gameAddGameInfo(gameInfo).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getGames = function() {
    return this._apiGame.__gameGetAllGamesSorted().then((function(_this) {
      return function(response) {
        _this.Games = response.payload;
        return response.payload;
      };
    })(this));
  };

  Snowflake.prototype.getGamesByPlatform = function(platform) {
    return this._apiGame.__gameGetGamesByPlatform(platform).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getEmulatorFlags = function(emulator) {
    return this._apiGame.__gameGetFlags(emulator).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getFlagValues = function(emulator, gameId) {
    return this._apiGame.__gameGetFlagValues(emulator, gameId).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.setFlagValue = function(emulator, gameId, flagName, flagValue) {
    return this._apiGame.__gameSetFlagValues(emulator, gameId, flagName, flagValue).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getFlagDefaultValues = function(emulator) {
    return this._apiGame.__gameGetFlagDefaultValues(emulator).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.setFlagDefaultValue = function(emulator, flagName, flagValue) {
    return this._apiGame.__gameSetFlagValues(emulator, flagName, flagValue).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.startGame = function(emulator, gameId) {
    return this._apiGame.__gameStartGame(emulatorId, gameId).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getPlatforms = function() {
    return this._apiPlatform.__platformGetPlatforms().then((function(_this) {
      return function(response) {
        _this.Platforms = response.payload;
        return response.payload;
      };
    })(this));
  };

  Snowflake.prototype.getPreferences = function(platformId) {
    return this._apiPlatform.__platformGetPreferences(platformId).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.setPreference = function(platformId, preferenceName, preferenceValue) {
    return this._apiPlatform.__platformSetPreference(platformId(preferenceName(preferenceValue))).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getAllPlugins = function() {
    return this._apiSystem.__systemGetAllPlugins().then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getEmulatorBridges = function() {
    return this._apiSystem.__systemGetEmulatorBridges().then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getEmulatorBridgesByPlatform = function(platform) {
    return this._apiSystem.__systemGetEmulatorBridgesByPlatform(platform).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getScrapers = function() {
    return this._apiSystem.__systemGetScrapers().then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getScrapersByPlatform = function() {
    return this._apiSystem.__systemGetScrapersByPlatform(platform).then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.getAjaxMethods = function() {
    return this._apiSystem.__systemGetAllAjaxMethods().then(function(response) {
      return response.payload;
    });
  };

  Snowflake.prototype.shutdownCore = function() {
    return this._apiSystem.__systemShutdownCore()["catch"](function(err) {
      return {
        'success': true
      };
    });
  };

  Snowflake.prototype.getControllers = function() {
    return this._apiController.__controllerGetControllers().then((function(_this) {
      return function(response) {
        _this.Controllers = response.payload;
        return response.payload;
      };
    })(this));
  };

  Snowflake.prototype.getGamesArray = function() {
    return this.getGames().then(function(response) {
      return Array.prototype.concat.apply([], Object.keys(response).map(function(index, value) {
        return response[index];
      }));
    });
  };

  Snowflake.prototype.getPlatformsArray = function() {
    return this.getPlatforms().then(function(response) {
      return Object.keys(response).map(function(index, value) {
        return response[index];
      });
    });
  };

  Snowflake.prototype.getControllersArray = function() {
    return this.getControllers().then(function(response) {
      return Object.keys(response).map(function(index, value) {
        return response[index];
      });
    });
  };

  return Snowflake;

})();
