{SnowflakeEndpoint, Snowflake} = require './snowflake.js'

window.snowflake_ws = new Snowflake new SnowflakeEndpoint "ws://localhost:30003"
window.snowflake_ajax = new Snowflake new SnowflakeEndpoint "http://localhost:30001"
