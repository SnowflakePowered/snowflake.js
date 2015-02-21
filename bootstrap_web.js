var Snowflake, SnowflakeEndpoint, _ref;

_ref = require('./snowflake.js'), SnowflakeEndpoint = _ref.SnowflakeEndpoint, Snowflake = _ref.Snowflake;

window.snowflake_ws = new Snowflake(new SnowflakeEndpoint("ws://localhost:30003"));

window.snowflake_ajax = new Snowflake(new SnowflakeEndpoint("http://localhost:30001"));

//# sourceMappingURL=bootstrap_web.js.map
