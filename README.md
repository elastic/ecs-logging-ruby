# ecs-logging-ruby

This set of libraries allows you to transform your application logs to structured logs that comply with the [Elastic Common Schema (ECS)](https://www.elastic.co/guide/en/ecs/current/ecs-reference.html).
In combination with [filebeat](https://www.elastic.co/products/beats/filebeat) you can send your logs directly to Elasticsearch and leverage [Kibana's Logs UI](https://www.elastic.co/guide/en/infrastructure/guide/current/logs-ui-overview.html) to inspect all logs in one single place.
See [ecs-logging](https://github.com/elastic/ecs-logging) for other ECS logging libraries and more resources about ECS & logging.

---

**Please note** that this library is in a **beta** version and backwards-incompatible changes might be introduced in future releases. While we strive to comply to [semver](https://semver.org/), we can not guarantee to avoid breaking changes in minor releases.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ecs-logging'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ecs-logging

## Usage with Rack

```ruby
use Rack::EcsLogger, Logger.new($stdout)
```

## License

Apache 2.0
