# kafka_broker

Primary resource for installing, configuring, formatting, and running an Apache Kafka broker.

## Actions

| Action | Description |
|--------|-------------|
| `:create` | Creates user/group, directories, install, config, optional KRaft storage format, and systemd service. |
| `:delete` | Stops and removes the service, config, install artifacts, log directory, and Kafka log dirs. |

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `version` | String | `'4.2.0'` | Kafka version to install. |
| `scala_version` | String | `'2.13'` | Scala artifact version. |
| `broker_config` | Hash | `{}` | Kafka broker configuration rendered to `server.properties`. |
| `cluster_id` | String, nil | `nil` | KRaft cluster ID used when formatting storage. |
| `format_storage` | true, false | `false` | Run `kafka-storage.sh format --ignore-formatted`. |
| `automatic_start` | true, false | `false` | Start the service after convergence. |
| `automatic_restart` | true, false | `false` | Restart service after configuration changes. |
| `user` | String | `'kafka'` | Kafka system user. |
| `group` | String | `'kafka'` | Kafka system group. |
| `manage_user` | true, false | `true` | Create user and group. |
| `install_dir` | String | `'/opt/kafka'` | Stable Kafka install path. |
| `config_dir` | String | `'/opt/kafka/config'` | Kafka configuration directory. |
| `log_dir` | String | `'/var/log/kafka'` | Kafka log directory. |

## Examples

```ruby
kafka_broker 'default' do
  automatic_start true
  format_storage true
  cluster_id 'MkU3OEVBNTcwNTJENDM2Qk'
  broker_config(
    'process.roles' => 'broker,controller',
    'node.id' => 1,
    'controller.quorum.voters' => '1@localhost:9093',
    'listeners' => 'PLAINTEXT://:9092,CONTROLLER://:9093',
    'advertised.listeners' => 'PLAINTEXT://localhost:9092',
    'controller.listener.names' => 'CONTROLLER',
    'listener.security.protocol.map' => 'CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT',
    'inter.broker.listener.name' => 'PLAINTEXT',
    'log.dirs' => '/var/lib/kafka/data'
  )
end
```
