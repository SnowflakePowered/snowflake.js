reqwest = require './bower_components/reqwest/reqwest.js'


class SnowflakeApi
  constructor: (@apiUrl) ->
    @status = "test"

  apiCall: (meters) ->
    console.log @apiUrl
    reqwest {
      url: @apiUrl,
      method: 'get'
    }

exports.SnowflakeApi = SnowflakeApi
exports.status = status
