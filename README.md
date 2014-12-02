# kafka cookbook

[![Build Status](https://travis-ci.org/mthssdrbrg/kafka-cookbook.svg?branch=master)](https://travis-ci.org/mthssdrbrg/kafka-cookbook)

Installs Kafka `v0.8.1.1`, and probably any newer versions.

Based on the Kafka cookbook released by WebTrends (thanks!), but with a few
notable differences:

* does not depend on runit cookbook.
* does not depend on zookeeper cookbook, thus it will not search for nodes with
  a specific role or such, that is left up to you to decide.
* only tested on Vagrant boxes.
* intended to be used by wrapper cookbooks.

## Requirements

This cookbook does not depend on any specific cookbooks, but it requires that
java is installed on the system, thus the `java` cookbook is recommended.

Ruby 1.9.3+ and Chef 11.6.0+.

### Platform

* Amazon Linux
* CentOS 6.5 and 7
* Debian 7.4
* Fedora 20
* Ubuntu 14.04

Might work on other platforms / versions, but these are the ones that are
included in `.kitchen.yml` and/or tested in the wild, so YMMV.

## Attributes

In order to keep the README in some kind of manageable state (and thus in sync
with attributes), attributes are documented inline (in the `attribute` files
that is).

Attributes concerning configuring of a Kafka broker are to be set under the
`broker` namespace, and one can choose which ever syntax they prefer the most,
the following are all valid ways to define broker configuration:

```ruby
node.default.kafka.broker[:log_dirs] = %w[/tmp/kafka-logs]
node.default.kafka.broker['log.dirs'] = %w[/tmp/kafka-logs]
node.default.kafka.broker.log.dirs = %w[/tmp/kafka-logs]
node.default[:kafka][:broker][:log][:dirs] = %w[/tmp/kafka-logs]
```

A warning regarding the "dotted" notation, it doesn't play very well when
setting attributes like `default.replication.factor` or
`fetch.purgatory.purge.interval.requests` due to fairly obvious reasons
(`default` and `fetch` are also methods).

Refer to the official documentation for the version of Kafka that you're
installing.
Documentation for the latest release can be found [over here](https://kafka.apache.org/documentation.html#brokerconfigs).

## Recipes

This section describes the different recipes that are available.

### default

Downloads and installs Kafka from the official binary releases.
Defaults to installing `v0.8.1.1` of Kafka.

### Controlling restart of kafka brokers in a cluster

Any changes made to Kafka configuration, could result in the restart of Kafka broker
depending on configuration. If chef client is run as a daemon on all the nodes in a
kafka cluster, this can result in all of the kafka brokers being brought time at the
sametime, resulting in unavailability of service.

If unavailability is an issue, this cookbook provides an option to implement custom
logic to control the restart of kafka brokers so that all the instances in a cluster
are not stopped at the same time. For e.g. the custom logic can be something like a node
 can restart if it can acquire a lock.

By default the resources in the recipe [`` _coordinate.rb ``](https://github.com/mthssdrbrg/kafka-cookbook/blob/master/recipes/_coordinate.rb) in this cookbook performs the
start/restart of the `` kafka `` service. If custom logic needs to be implemented, this recipe
can be replaced with a new recipe and the recipe name need to be updated in the attribute `` default.kafka.start_coordination.recipe ``.
The only requrirement is that the new recipe needs to have a `` ruby_block `` with `` 'coordinate-kafka-start' ``
as ID. The following is a sample recipe which can replace the default `` _coordinate `` recipe.

```
    ruby_block "coordinate-kafka-start" do
       block do
          Chef::Log.info (" Custom recipe to coordinate Kafka start is used")
        end
        action :create
        notifies :create, 'ruby_block[restart_coordination]', :delayed
     end
     ruby_block "restart_coordination" do
       block do
          Chef::Log.info ("Need to implement the process to coordinate the restart process like using ZK")
       end
       action :nothing
       notifies :restart, 'service[kafka]', :delayed
     end
     service 'kafka' do
        provider kafka_init_opts[:provider]
        supports start: true, stop: true, restart: true, status: true
        action kafka_service_actions
     end
     ruby_block "restart_coordination_cleanup" do
       block do
          Chef::Log.info ("Implement any cleanup logic required after restart like releasing locks")
       end
       action :nothing
     end
```
Please refer to [issue #58](https://github.com/mthssdrbrg/kafka-cookbook/issues/58) to read about the background of this feature.

## Copyright

Copyright :: 2013-2014 Mathias Söderberg and contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add-component-x`)
3. Write your change
4. Check that your change works, for example with Vagrant
5. Submit a Pull Request using Github
