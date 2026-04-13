# kafka cookbook

Apache Kafka broker management through the `kafka_broker` custom resource.

## Requirements

- Chef Infra Client `>= 15.3`
- Java 17 or newer installed separately
- Linux with `systemd`

This cookbook installs Kafka from the official Apache binary tarball. It does
not manage Java, ZooKeeper, or external coordination services.

## Resource

See [documentation/kafka_broker.md](documentation/kafka_broker.md) for the full API.

### Minimal KRaft example

```ruby
kafka_broker 'default' do
  automatic_start true
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

### ZooKeeper mode example

```ruby
kafka_broker 'default' do
  automatic_start true
  broker(
    'broker.id' => 1,
    'listeners' => 'PLAINTEXT://127.0.0.1:9092',
    'advertised.listeners' => 'PLAINTEXT://127.0.0.1:9092',
    'log.dirs' => ['/var/lib/kafka/data'],
    'zookeeper.connect' => '127.0.0.1:2181'
  )
end
```

## Testing

```sh
cookstyle
chef exec rspec
KITCHEN_LOCAL_YAML=kitchen.dokken.yml kitchen test default-ubuntu-2404 --destroy=always
```
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
