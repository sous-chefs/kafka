# kafka_service

Manages the Apache Kafka systemd unit.

## Actions

| Action | Description |
|--------|-------------|
| `:create` | Creates and enables `kafka.service`. |
| `:start` | Creates, enables, and starts `kafka.service`. |
| `:restart` | Restarts `kafka.service`. |
| `:stop` | Stops `kafka.service`. |
| `:delete` | Stops, disables, and deletes `kafka.service`. |

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `service_name` | String | `'kafka'` | systemd service name. |
| `install_dir` | String | `'/opt/kafka'` | Stable Kafka install path. |
| `config_dir` | String | `'/opt/kafka/config'` | Kafka configuration directory. |
| `env_path` | String | platform default | Environment file path. |
| `user` | String | `'kafka'` | Service user. |
| `group` | String | `'kafka'` | Service group. |
| `ulimit_file` | Integer, String, nil | `nil` | Optional `LimitNOFILE` value. |
| `kill_timeout` | Integer, String | `10` | systemd stop timeout. |

## Examples

```ruby
kafka_service 'default' do
  automatic_start true
  action :start
end
```
