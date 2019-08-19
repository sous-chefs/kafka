# kafka cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/kafka.svg)](https://supermarket.chef.io/cookbooks/kafka)
[![Build Status](https://img.shields.io/circleci/project/github/sous-chefs/kafka/master.svg)](https://circleci.com/gh/sous-chefs/kafka)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Installs and configures Kafka `>= v0.8.1`.

Initially based on the Kafka cookbook released by Webtrends (thanks!), but with a few
notable differences:

- does not depend on runit cookbook.
- does not depend on zookeeper cookbook, thus it will not search for nodes with
  a specific role or such, that is left up to you to decide.
- intended to be used by wrapper cookbooks.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

This cookbook does not depend on any specific cookbooks, but it requires that
java is installed on the system, thus the `java` cookbook is recommended.

Furthermore, Kafka requires ZooKeeper for coordination, and this cookbook does
not install or manage ZooKeeper to any extent.
A general recommendation is to not run Kafka and ZooKeeper on the same hardware.

Chef 13+

### Platform

- Amazon Linux
- CentOS 6 and 7
- Debian 7 and 8
- Fedora 21
- Ubuntu 14.04

The platforms / versions listed above are the ones that are included in
`.kitchen.yml` and/or tested in the wild, so it might work on other platforms as
well, YMMV.

## Attributes

In order to keep the README in some kind of manageable state (and thus in sync
with attributes), attributes are documented inline (in the `attribute` files
that is).

Attributes concerning configuration of a Kafka broker are to be set under the
`broker` namespace, as such:

```ruby
node.default['kafka']['broker']['log.dirs'] = %w[/tmp/kafka-logs]
node.default['kafka']['broker']['num.io.threads'] = 4
node.default['kafka']['broker']['zookeeper.connect'] = %w[localhost:2181]
```

The attribute names match the configuration names that Kafka uses to make it
easier to support new and old versions of Kafka simultaneously, by avoiding
"hardcoded" attribute names for configuration options, so please refer to the
official documentation for the release at your hand.

Refer to the official documentation for the version of Kafka that you're
installing.
Documentation for the latest release can be found [over here](https://kafka.apache.org/documentation.html#brokerconfigs).

## Recipes

This section describes the different recipes that are available.

### default

Downloads and installs Kafka from the official binary releases.
Defaults to installing `v1.1.1` of Kafka.

## Controlling restart of Kafka brokers in a cluster

Any changes made to the broker configuration could result in a restart of the
Kafka broker, if the `kafka.automatic_restart` attribute is set to `true`.
If Chef runs as a daemon on all of the nodes this could result in all of the Kafka
brokers being brought down at the same time, resulting in unavailability of
service.

If unavailability is an issue, this cookbook provides an option to implement custom
logic to control the restart of Kafka brokers so that not all of the brokers in
a cluster are stopped at the same time.
For example the custom logic can be something along the lines of acquiring a lock
in ZooKeeper and when held the broker is allowed to restart.
Be aware that a restart might take quite some time if you're using controlled
shutdown and have a lot of partitions, and Chef usually have some timeout for
each resource.

By default the resources in the [`_coordinate`](https://github.com/mthssdrbrg/kafka-cookbook/blob/master/recipes/_coordinate.rb)
recipe performs the start/restart of the `kafka` service.
If custom logic needs to be implemented, this recipe can be replaced with
another recipe, but don't forget to update the `kafka.start_coordination.recipe`
attribute.

The only requirement is that the new recipe has a `ruby_block` resource with
`'coordinate-kafka-start'` as ID.
The following is a sample recipe that shows roughly what one can do with this
feature.

```ruby
ruby_block 'coordinate-kafka-start' do
  block do
    Chef::Log.info 'Custom recipe to coordinate Kafka start/restart'
  end
  action :nothing
  notifies :create, 'ruby_block[restart-coordination]', :delayed
end

ruby_block 'restart-coordination' do
  block do
    Chef::Log.info 'Implement the process to coordinate the restart, like using ZK'
  end
  action :nothing
  # `kafka_service_resource` is a helper method that will return the correct
  # resource name depending on whether you're using `runit` or not.
  notifies :restart, kafka_service_resource, :delayed
  notifies :create, 'ruby_block[restart-coordination-cleanup]', :delayed
end

ruby_block 'restart-coordination-cleanup' do
  block do
    Chef::Log.info 'Implement any cleanup logic required after restart like releasing locks'
  end
  action :nothing
end
```

Please refer to [issue #58](https://github.com/mthssdrbrg/kafka-cookbook/issues/58) for background of this feature.

## FAQ

### Kafka dies for no apparent reason (ulimit)

Depending on your system / infrastructure setup you might run into issues with
Kafka just sporadically dying for no obvious reason.
One thing you might want to look into is the file handle limit as Kafka tend to
keep a lot file handles open due to socket connections (depends on the number of
brokers, producers and consumers) and the actual data log files (depends on
the number of partitions and log segment and/or log roll settings).

It's possible to set a specific `ulimit` for Kafka using the `node['kafka']['ulimit_file']`
attribute.
If this value is not set, Kafka will use whatever the system default is, which
as stated previously might not be enough, so it might be wise to set a higher
limit.

### How do I get started locally? (minimal required setup)

If you want to hit the ground running and just setup a single broker (or a
cluster for that matter) locally, these are the necessary `broker` attributes
that needs to be set (assumes that you have ZooKeeper running on port 2181
locally):

```ruby
node.default['kafka']['broker']['zookeeper.connect'] = 'localhost:2181'
# This shouldn't normally be necessary, but might need to be set explicitly
# if you're having trouble connecting to the brokers.
node.default['kafka']['broker']['hostname'] = '127.0.0.1' # or perhaps 'localhost'
```

If you plan on running a cluster locally you will want to set separate
values for the following configuration options:

```ruby
node.default['kafka']['broker']['broker.id'] = <id>
node.default['kafka']['broker']['port'] = <port>
node.default['kafka']['broker']['log.dirs'] = <dir path>
```

Other than that things should work as expected, though depending on what
platform you're running on, you might want to change the install and config
directories as well. See `attributes/default.rb` and `recipes/_defaults.rb` for
the default path regarding directories that Kafka will use.

### Kafka killed prematurely (kill timeout)

When using `controlled shutdown` and either `systemd` or `upstart` as init
system you might run into issues with Kafka being killed before it has managed
to shutdown completely, resulting in long recovery times.

Not sure if it's possible to configure either `systemd` or `upstart` to not
automatically kill processes, but a workaround is to set `kafka.kill_timeout` to
a sufficiently high value.

## Contributing

- Fork the repository on Github
- Create a named feature branch (like `add-component-x`)
- Write your change
- Check that your change works, for example with Vagrant
- Submit a Pull Request using Github

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
