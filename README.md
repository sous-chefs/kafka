# kafka cookbook

[![Build Status](https://travis-ci.org/mthssdrbrg/kafka-cookbook.png?branch=master)](https://travis-ci.org/mthssdrbrg/kafka-cookbook)

Installs Kafka `v0.8.0`, and probably any newer versions.

Based on the Kafka cookbook released by WebTrends (thanks!), but with a few
notable differences:

* supports both source and binary releases (`>= v0.8.0`).
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

* CentOS 6.5
* Debian 7.4
* Fedora 20
* Ubuntu 14.04

Might work on other platforms / versions, but these are the ones that are
included in `.kitchen.yml`, so YMMV.

## Attributes

In order to keep the README in some kind of manageable state (and thus in sync
with attributes), attributes are documented inline (in the `attribute` files
that is).

Attributes concerning configuring of a Kafka broker are to be set under the
`broker` namespace, and one can choose which ever syntax they prefer the most,
the following are all valid ways to define broker configuration:

```ruby
node.default.broker[:log_dirs] = %w[/tmp/kafka-logs]
node.default.broker['log.dirs'] = %w[/tmp/kafka-logs]
node.default.broker.log.dirs = %w[/tmp/kafka-logs]
node.default[:broker][:log][:dirs] = %w[/tmp/kafka-logs]
```

A warning regarding the "dotted" notation, it doesn't play very well when
setting attributes like `default.replication.factor` or
`fetch.purgatory.purge.interval.requests` due to fairly obvious reasons
(`default` and `fetch` are also methods).

Refer to the official documentation for the version of Kafka that you're
installing.

## Recipes

This section describes the different recipes that exists, and how to use them.

### default

Includes either `source` or `binary` recipe depending on what
`node.kafka.install_method` is set to (`:source, :binary`).

### source

Downloads, compiles and installs Kafka from the official source releases.
Defaults to installing `v0.8.1.1` of Kafka.

### binary

Downloads and installs Kafka from the official binary releases.
Defaults to installing `v0.8.1.1` of Kafka.

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
