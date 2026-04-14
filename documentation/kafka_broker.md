# kafka_broker

Install, configure, and manage an Apache Kafka broker from the official Apache binary release.

## Actions

| Action    | Description                                                                                                            |
|-----------|------------------------------------------------------------------------------------------------------------------------|
| `:create` | Installs Kafka, renders configuration, formats KRaft storage when requested, and manages the systemd service (default) |
| `:delete` | Stops the service and removes the managed Kafka installation artifacts                                                 |

## Properties

| Property               | Type                 | Default                                   | Description                                                 |
|------------------------|----------------------|-------------------------------------------|-------------------------------------------------------------|
| `version`              | String               | `'3.9.1'`                                 | Kafka version to install                                    |
| `scala_version`        | String               | `'2.13'`                                  | Scala build to download                                     |
| `base_url`             | String               | `'https://archive.apache.org/dist/kafka'` | Apache download base URL                                    |
| `checksum`             | String               | upstream SHA-256                          | Checksum for the Kafka tarball                              |
| `install_dir`          | String               | `'/opt/kafka'`                            | Symlink path for the active Kafka installation              |
| `version_install_dir`  | String               | ``"#{install_dir}-#{version}"``           | Version-specific install directory                          |
| `config_dir`           | String               | ``"#{install_dir}/config"``               | Kafka configuration directory                               |
| `log_dir`              | String               | `'/var/log/kafka'`                        | Kafka log directory                                         |
| `jmx_port`             | Integer, String      | `9999`                                    | JMX port                                                    |
| `jmx_opts`             | String               | JMX remote flags                          | Additional JMX options                                      |
| `heap_opts`            | String               | `'-Xms1G -Xmx1G'`                         | Heap settings for the broker JVM                            |
| `generic_opts`         | String, nil          | `nil`                                     | Additional `KAFKA_OPTS` content                             |
| `gc_log_opts`          | String               | Java 17 GC logging flags                  | GC logging configuration                                    |
| `log4j_opts`           | String               | points at `log4j.properties`              | Log4j JVM flags                                             |
| `jvm_performance_opts` | String               | G1GC tuning                               | JVM performance options                                     |
| `user`                 | String               | `'kafka'`                                 | System user that runs the broker                            |
| `group`                | String, Integer      | `'kafka'`                                 | System group that owns Kafka files                          |
| `manage_user`          | true, false          | `true`                                    | Create the Kafka user and group when true                   |
| `uid`                  | String, Integer, nil | `nil`                                     | Optional UID override                                       |
| `gid`                  | String, Integer, nil | `nil`                                     | Optional GID override                                       |
| `service_name`         | String               | `'kafka'`                                 | Systemd unit name without the `.service` suffix             |
| `ulimit_file`          | Integer, String, nil | `nil`                                     | Optional open-file limit for the broker service             |
| `automatic_start`      | true, false          | `false`                                   | Start the service during converge                           |
| `automatic_restart`    | true, false          | `false`                                   | Restart the service when config files change                |
| `kill_timeout`         | Integer, String      | `10`                                      | `TimeoutStopSec` value for the systemd unit                 |
| `manage_java`          | true, false          | `true`                                    | Install and manage the Java runtime needed by Kafka         |
| `java_version`         | String               | `'17'`                                    | LTS Java version to install when `manage_java` is true      |
| `cluster_id`           | String, nil          | `nil`                                     | Required for KRaft storage formatting                       |
| `broker`               | Hash                 | `{}`                                      | `server.properties` options keyed by Kafka config names     |
| `log4j`                | Hash                 | `{}`                                      | Overrides merged into the default `log4j.properties` config |

## Examples

### Basic single-node KRaft broker

```ruby
kafka_broker 'default' do
  automatic_start true
  java_version '17'
  cluster_id 'MkU3OEVBNTcwNTJENDM2Qk'
  broker(
    'process.roles' => 'broker,controller',
    'node.id' => 1,
    'controller.quorum.voters' => '1@127.0.0.1:9093',
    'listeners' => 'PLAINTEXT://127.0.0.1:9092,CONTROLLER://127.0.0.1:9093',
    'advertised.listeners' => 'PLAINTEXT://127.0.0.1:9092',
    'listener.security.protocol.map' => 'CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT',
    'controller.listener.names' => 'CONTROLLER',
    'inter.broker.listener.name' => 'PLAINTEXT',
    'log.dirs' => ['/var/lib/kafka/data'],
    'offsets.topic.replication.factor' => 1,
    'transaction.state.log.replication.factor' => 1,
    'transaction.state.log.min.isr' => 1,
    'group.initial.rebalance.delay.ms' => 0
  )
end
```

### ZooKeeper-backed broker

```ruby
kafka_broker 'default' do
  automatic_start true
  manage_java false
  broker(
    'broker.id' => 1,
    'listeners' => 'PLAINTEXT://127.0.0.1:9092',
    'advertised.listeners' => 'PLAINTEXT://127.0.0.1:9092',
    'log.dirs' => ['/var/lib/kafka/data'],
    'zookeeper.connect' => '127.0.0.1:2181'
  )
end
```

When `manage_java` is left at its default, the resource installs Java automatically. It uses Eclipse Temurin packages on most supported Linux platforms and Amazon Corretto on Amazon Linux and EL 10-family platforms where that path is more reliable.
Managed Java on Amazon Linux and EL 10-family platforms currently supports Java 17 only; use `manage_java false` if you need to supply another JDK there.

### Remove a broker installation

```ruby
kafka_broker 'default' do
  broker('log.dirs' => ['/var/lib/kafka/data'])
  action :delete
end
```
