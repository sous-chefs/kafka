# kafka_config

Writes Apache Kafka configuration files and environment settings.

## Actions

| Action | Description |
|--------|-------------|
| `:create` | Creates the config directory, log directory, environment file, `server.properties`, and `log4j.properties`. |
| `:delete` | Removes the managed configuration files and config directory. |

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `broker_config` | Hash | `{}` | Pass-through Kafka broker configuration rendered to `server.properties`. |
| `log4j_config` | Hash, nil | generated | Log4j configuration rendered to `log4j.properties`. |
| `config_dir` | String | `'/opt/kafka/config'` | Kafka configuration directory. |
| `log_dir` | String | `'/var/log/kafka'` | Kafka log directory. |
| `env_path` | String | platform default | Environment file path. |
| `heap_opts` | String | `'-Xmx1G -Xms1G'` | Kafka heap options. |
| `jmx_port` | Integer, String | `9999` | JMX port. |
| `automatic_restart` | true, false | `false` | Restart `kafka.service` when configuration changes. |

## Examples

```ruby
kafka_config 'default' do
  broker_config(
    'process.roles' => 'broker,controller',
    'node.id' => 1
  )
end
```
