{SnowflakeApi} = require './snowflake.js'

window.snowflake_ws = new SnowflakeApi "ws://localhost:30003"
window.snowflake_ajax = new SnowflakeApi "http://localhost:30001", "ajax"
