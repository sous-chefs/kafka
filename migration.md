# Migration Guide

This release migrates the cookbook from recipes and node attributes to custom resources.

## Breaking Changes

* `recipe[kafka]` and the private recipes under `recipes/` are removed.
* `attributes/default.rb` is removed.
* Node attributes under `node['kafka']` are replaced by properties on `kafka_broker`,
  `kafka_install`, `kafka_config`, and `kafka_service`.
* sysv, upstart, and runit service support is removed. The cookbook manages systemd only.
* The default Kafka version changes from `1.1.1` with Scala `2.11` to Kafka `4.2.0` with Scala
  `2.13`.
* ZooKeeper-oriented examples are replaced with KRaft-oriented examples.

## Attribute Mapping

| Old attribute                            | New property           |
| ---------------------------------------- | ---------------------- |
| `node['kafka']['version']`               | `version`              |
| `node['kafka']['scala_version']`         | `scala_version`        |
| `node['kafka']['base_url']`              | `base_url`             |
| `node['kafka']['checksum']`              | `checksum`             |
| `node['kafka']['md5_checksum']`          | `md5_checksum`         |
| `node['kafka']['sha512_checksum']`       | `sha512_checksum`      |
| `node['kafka']['install_dir']`           | `install_dir`          |
| `node['kafka']['version_install_dir']`   | `version_install_dir`  |
| `node['kafka']['build_dir']`             | `build_dir`            |
| `node['kafka']['log_dir']`               | `log_dir`              |
| `node['kafka']['config_dir']`            | `config_dir`           |
| `node['kafka']['user']`                  | `user`                 |
| `node['kafka']['group']`                 | `group`                |
| `node['kafka']['manage_user']`           | `manage_user`          |
| `node['kafka']['uid']`                   | `uid`                  |
| `node['kafka']['gid']`                   | `gid`                  |
| `node['kafka']['heap_opts']`             | `heap_opts`            |
| `node['kafka']['generic_opts']`          | `generic_opts`         |
| `node['kafka']['gc_log_opts']`           | `gc_log_opts`          |
| `node['kafka']['log4j_opts']`            | `log4j_opts`           |
| `node['kafka']['jvm_performance_opts']`  | `jvm_performance_opts` |
| `node['kafka']['jmx_port']`              | `jmx_port`             |
| `node['kafka']['jmx_opts']`              | `jmx_opts`             |
| `node['kafka']['ulimit_file']`           | `ulimit_file`          |
| `node['kafka']['automatic_start']`       | `automatic_start`      |
| `node['kafka']['automatic_restart']`     | `automatic_restart`    |
| `node['kafka']['kill_timeout']`          | `kill_timeout`         |
| `node['kafka']['broker']`                | `broker_config`        |
| `node['kafka']['log4j']`                 | `log4j_config`         |

## Before

```ruby
node.default['kafka']['broker']['zookeeper.connect'] = 'localhost:2181'
node.default['kafka']['broker']['broker.id'] = 1

include_recipe 'kafka'
```

## After

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
