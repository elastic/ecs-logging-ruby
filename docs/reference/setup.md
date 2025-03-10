---
mapped_pages:
  - https://www.elastic.co/guide/en/ecs-logging/ruby/current/setup.html
navigation_title: Get started
---

# Get started with ECS Logging Ruby [setup]


## Step 1: Set up application logging [setup-step-1]


### Add the dependency [_add_the_dependency]

Add this line to your application’s Gemfile:

```ruby
gem 'ecs-logging'
```

Execute with:

```cmd
bundle install
```

Alternatively, you can install the package yourself with:

```cmd
gem install ecs-logging
```


### Configure [_configure]

`Ecs::Logger` is a subclass of Ruby’s own [`Logger`](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.md) and responds to the same methods.

For example:

```ruby
require 'ecs_logging/logger'

logger = EcsLogging::Logger.new($stdout)
logger.info('my informative message')
logger.warn { 'be aware that…' }
logger.error('a_progname') { 'oh no!' }
```

Logs the following JSON to `$stdout`:

```json
{"@timestamp":"2020-11-24T13:32:21.329Z","log.level":"INFO","message":"very informative","ecs.version":"1.4.0"}
 {"@timestamp":"2020-11-24T13:32:21.330Z","log.level":"WARN","message":"be aware that…","ecs.version":"1.4.0"}
 {"@timestamp":"2020-11-24T13:32:21.331Z","log.level":"ERROR","message":"oh no!","ecs.version":"1.4.0","process.title":"a_progname"}
```

Additionally, it allows for adding additional keys to messages.

For example:

```ruby
logger.info('ok', labels: { my_label: 'value' }, 'trace.id': 'abc-xyz')
```

Logs the following:

```json
{
  "@timestamp":"2020-11-24T13:32:21.331Z",
  "log.level":"INFO",
  "message":"oh no!",
  "ecs.version":"1.4.0",
  "labels":{"my_label":"value"},
  "trace.id":"abc-xyz"
}
```

To include info about where the log was called, call the methods with `include_origin: true`, like `logger.warn('Hello!', include_origin: true)`. This logs:

```json
{
  "@timestamp":"2020-11-24T13:32:21.331Z",
  "log.level":"WARN",
  "message":"Hello!",
  "ecs.version":"1.4.0",
  "log.origin": {
    "file.line": 123,
    "file.name": "my_file.rb",
    "function": "call"
  }
}
```


### Rack configuration [_rack_configuration]

```ruby
use EcsLogging::Middleware, $stdout
```

Example output:

```json
{
  "@timestamp":"2020-12-07T13:44:04.568Z",
  "log.level":"INFO",
  "message":"GET /",
  "ecs.version":"1.4.0",
  "client":{
    "address":"127.0.0.1"
  },
  "http":{
    "request":{
      "method":"GET",
      "body.bytes":"0"
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


## Step 2: Enable APM log correlation (optional) [setup-step-2]

If you are using the Elastic APM Ruby agent, [enable log correlation](apm-agent-ruby://reference/logs.md).


## Step 3: Configure Filebeat [setup-step-3]

:::::::{tab-set}

::::::{tab-item} Log file
1. Follow the [Filebeat quick start](beats://reference/filebeat/filebeat-installation-configuration.md)
2. Add the following configuration to your `filebeat.yaml` file.

For Filebeat 7.16+

```yaml
filebeat.inputs:
- type: filestream <1>
  paths: /path/to/logs.json
  parsers:
    - ndjson:
      overwrite_keys: true <2>
      add_error_key: true <3>
      expand_keys: true <4>

processors: <5>
  - add_host_metadata: ~
  - add_cloud_metadata: ~
  - add_docker_metadata: ~
  - add_kubernetes_metadata: ~
```

1. Use the filestream input to read lines from active log files.
2. Values from the decoded JSON object overwrite the fields that {{filebeat}} normally adds (type, source, offset, etc.) in case of conflicts.
3. {{filebeat}} adds an "error.message" and "error.type: json" key in case of JSON unmarshalling errors.
4. {{filebeat}} will recursively de-dot keys in the decoded JSON, and expand them into a hierarchical object structure.
5. Processors enhance your data. See [processors](beats://reference/filebeat/filtering-enhancing-data.md) to learn more.


For Filebeat < 7.16

```yaml
filebeat.inputs:
- type: log
  paths: /path/to/logs.json
  json.keys_under_root: true
  json.overwrite_keys: true
  json.add_error_key: true
  json.expand_keys: true

processors:
- add_host_metadata: ~
- add_cloud_metadata: ~
- add_docker_metadata: ~
- add_kubernetes_metadata: ~
```
::::::

::::::{tab-item} Kubernetes
1. Make sure your application logs to stdout/stderr.
2. Follow the [Run Filebeat on Kubernetes](beats://reference/filebeat/running-on-kubernetes.md) guide.
3. Enable [hints-based autodiscover](beats://reference/filebeat/configuration-autodiscover-hints.md) (uncomment the corresponding section in `filebeat-kubernetes.yaml`).
4. Add these annotations to your pods that log using ECS loggers. This will make sure the logs are parsed appropriately.

```yaml
annotations:
  co.elastic.logs/json.overwrite_keys: true <1>
  co.elastic.logs/json.add_error_key: true <2>
  co.elastic.logs/json.expand_keys: true <3>
```

1. Values from the decoded JSON object overwrite the fields that {{filebeat}} normally adds (type, source, offset, etc.) in case of conflicts.
2. {{filebeat}} adds an "error.message" and "error.type: json" key in case of JSON unmarshalling errors.
3. {{filebeat}} will recursively de-dot keys in the decoded JSON, and expand them into a hierarchical object structure.
::::::

::::::{tab-item} Docker
1. Make sure your application logs to stdout/stderr.
2. Follow the [Run Filebeat on Docker](beats://reference/filebeat/running-on-docker.md) guide.
3. Enable [hints-based autodiscover](beats://reference/filebeat/configuration-autodiscover-hints.md).
4. Add these labels to your containers that log using ECS loggers. This will make sure the logs are parsed appropriately.

```yaml
labels:
  co.elastic.logs/json.overwrite_keys: true <1>
  co.elastic.logs/json.add_error_key: true <2>
  co.elastic.logs/json.expand_keys: true <3>
```

1. Values from the decoded JSON object overwrite the fields that {{filebeat}} normally adds (type, source, offset, etc.) in case of conflicts.
2. {{filebeat}} adds an "error.message" and "error.type: json" key in case of JSON unmarshalling errors.
3. {{filebeat}} will recursively de-dot keys in the decoded JSON, and expand them into a hierarchical object structure.
::::::

:::::::
For more information, see the [Filebeat reference](beats://reference/filebeat/configuring-howto-filebeat.md).

