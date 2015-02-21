{SnowflakeEndpoint} = require './snowflake.js'

window.snowflake_ws = new SnowflakeEndpoint "ws://localhost:30003"
window.snowflake_ajax = new SnowflakeEndpoint "http://localhost:30001"
