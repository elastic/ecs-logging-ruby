[![Jenkins](https://apm-ci.elastic.co/buildStatus/icon?job=apm-agent-ruby/ecs-logging-ruby-mbp/master)](https://apm-ci.elastic.co/job/apm-agent-ruby/job/ecs-logging-ruby-mbp/job/master/) 
# ecs-logging-ruby

This set of libraries allows you to transform your application logs to structured logs that comply with the [Elastic Common Schema (ECS)](https://www.elastic.co/guide/en/ecs/current/ecs-reference.html).
In combination with [filebeat](https://www.elastic.co/products/beats/filebeat) you can send your logs directly to Elasticsearch and leverage [Kibana's Logs UI](https://www.elastic.co/guide/en/infrastructure/guide/current/logs-ui-overview.html) to inspect all logs in one single place.
See [ecs-logging](https://github.com/elastic/ecs-logging) for other ECS logging libraries and more resources about ECS & logging.

---

**Please note** that this library is in a <del><strong>beta</strong></del> **in development** version and backwards-incompatible changes might be introduced in future releases. While we strive to comply to [semver](https://semver.org/), we can not guarantee to avoid breaking changes in minor releases.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ecs-logging'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ecs-logging

## Usage

`Ecs::Logger` is a subclass of Ruby's own [`Logger`](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html) and responds to the same methods.

```ruby
require 'ecs/logger'

logger = Ecs::Logger.new($stdout)
logger.info 'my informative message'
logger.warn { 'be aware that…' }
logger.error('a_progname') { 'oh no!' }
```

Logs the following JSON to `$stdout`:

```ndjson
 {"@timestamp":"2020-11-24T13:32:21.329Z","log.level":"INFO","message":"very informative","ecs.version":"1.4.0"}
 {"@timestamp":"2020-11-24T13:32:21.330Z","log.level":"WARN","message":"be aware that…","ecs.version":"1.4.0"}
 {"@timestamp":"2020-11-24T13:32:21.331Z","log.level":"ERROR","message":"oh no!","ecs.version":"1.4.0","process.title":"a_progname"}
```

Additionally, it allows for adding additional keys to messages, eg:

```ruby
logger.info 'ok', labels: { my_label: 'value' }, 'trace.id': 'abc-xyz'
```

Logs:

```json
{
  "@timestamp":"2020-11-24T13:32:21.331Z",
  "log.level":"ERROR",
  "message":"oh no!",
  "ecs.version":"1.4.0",
  "labels":{"my_label":"value"},
  "trace.id":"abc-xyz"
}
```

## Usage with Rack

```ruby
use EcsLogging::Middleware, $stdout
```

Example output:

```json
{
  "@timestamp":"2020-11-24T20:00:22.707Z",
  "log.level":"INFO",
  "message":"GET /",
  "ecs.version":"1.4.0",
  "http":{
    "request":{
      "method":"GET"
    }
  },
  "url":{
    "domain":"example.org",
    "path":"/",
    "port":"80",
    "scheme":"http"
  }
}
```

## License

Apache 2.0
