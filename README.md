# kafka cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/kafka.svg)](https://supermarket.chef.io/cookbooks/kafka)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Provides custom resources for installing and configuring Apache Kafka brokers.

This cookbook is a full custom-resource cookbook. It does not provide recipes or node attributes.
See [migration.md](migration.md) when upgrading from the legacy recipe API.

## Requirements

* Chef Infra Client 15.3 or later
* Java 17 or later installed by the caller
* systemd

Kafka is extracted from Apache binary tarballs. The `kafka_install` resource installs the platform
`tar` package when it converges.

See [LIMITATIONS.md](LIMITATIONS.md) for platform and Kafka version constraints.

## Resources

* [kafka_broker](documentation/kafka_broker.md)
* [kafka_install](documentation/kafka_install.md)
* [kafka_config](documentation/kafka_config.md)
* [kafka_service](documentation/kafka_service.md)

## Basic Usage

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

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook
maintainers working together to maintain important cookbooks. For more information, visit
[sous-chefs.org](https://sous-chefs.org/) or join the Chef Community Slack in
[#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Contributing

* Fork the repository on GitHub.
* Create a named feature branch.
* Write your change with tests.
* Run `cookstyle`, `chef exec rspec`, and the relevant Kitchen suites.
* Submit a pull request.

## Contributors

This project exists thanks to all the people who [contribute](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false).

## Backers

Thank you to all our backers.

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

## Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
