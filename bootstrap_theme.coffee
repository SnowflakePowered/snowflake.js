{SnowflakeEndpoint, Snowflake} = require './snowflake.js'

window.snowflake = new Snowflake new SnowflakeEndpoint "ws://localhost:30003"
