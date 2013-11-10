# kafka cookbook

[![Build Status](https://travis-ci.org/mthssdrbrg/kafka-cookbook.png?branch=master)](https://travis-ci.org/mthssdrbrg/kafka-cookbook)

Installs Kafka `0.8.0-beta1`, and probably any higher version, whenever they are
released. Given that they don't change URLs and the like.

Based on the Kafka cookbook released by WebTrends (thanks!), but with a few
notable differences:

* supports both source and binary releases (of Kafka `0.8.0-beta1`).
* does not depend on runit cookbook.
* does not depend on zookeeper cookbook, thus it will not search for nodes with
  a specific role or such, that is left up to you to decide.
* only tested on CentOS and Fedora Vagrant boxes.
* intended to be used by wrapper cookbooks.

## Requirements
* Java cookbook `~> 1.15.4`

## Attributes
This section describes all the attributes that are currently available for
configuration of where and how to install Kafka, as well as broker
configuration.

### default
The following attributes are used for setting up the environment for Kafka.

* `node[:kafka][:version]` - The Kafka version to install and use.
* `node[:kafka][:base_url]` - Base URL for Kafka releases.
* `node[:kafka][:checksum]` - SHA-256 checksum to use when downloading
  release.
* `node[:kafka][:md5_checksum]` - MD5 checksum to use when validating
  downloaded release.
* `node[:kafka][:scala_version]` - Scala version for Kafka.
* `node[:kafka][:install_dir]` - Location for Kafka to be installed.
* `node[:kafka][:log_dir]` - Location for Kafka log4j logs.
* `node[:kafka][:user]` - User to use for directories and configuration files.
* `node[:kafka][:group]` - Group for user defined above.
* `node[:kafka][:log_level]` - Log level for Kafka logs (and ZooKeeper, for further
  information see below).
* `node[:kafka][:log4j_config]` - Name of log4j configuration file (should
  include extension as well). Will use 'log4j.properties' by default.
* `node[:kafka][:config]` - Name of configuration file for Kafka (should
  include extension as well). Will use 'server.properties' by default.
* `node[:kafka][:jmx_port]` - JMX port for Kafka.
* `node[:kafka][:install_method]` - Decides how to install Kafka, by binary or
  from source. Defaults to `:source`.

### kafka
The following attributes are used for the Kafka broker configuration and are
divided into logical sections according to the official Kafka configuration.

#### General broker configuration attributes
* `node[:kafka][:broker_id]` - The id of the broker. This must be set to a unique integer
  for each broker. If not set, it will default to using the machine's ip address
  (without the dots).
* `node[:kafka][:host_name]` - Host name the broker will advertise. If not set, Kafka will
  use the host name returned from
`java.net.InetAddress.getCanonicalHostName()`, which might not be what you want.
* `node[:kafka][:port]` - The port Kafka will listen on for incoming requests.
* `node[:kafka][network_threads]` - The number of threads handling network requests.
* `node[:kafka][:io_threads]` - The number of threads doing disk I/O.
* `node[:kafka][num_partitions]` - The number of logical partitions per topic per server.
  More partitions allow greater parallelism for consumption, but also mean more
  files.

#### Socket server attributes
* `node[:kafka][:socket][:send_buffer_bytes]` - The send buffer (`SO_SNDBUF`) used by the
  socket server.
* `node[:kafka][:socket][:receive_buffer_bytes]` - The receive buffer (`SO_RCVBUF`) used by
  the socket server.
* `node[:kafka][:socket][:request_max_bytes]` - The maximum size of a request that the
  socket server will accept (protection against out of memory).

#### Log and flush policy attributes
* `node[:kafka][:log][:dirs]` - The directory under which Kafka will store log files.
* `node[:kafka][:log][:flush_interval_messages]` - The number of messages to accept before
  forcing a flush of data to disk.
* `node[:kafka][:log][:flush_interval_ms]` - The maximum amount of time a message can sit
  in a log before Kafka forces a flush to disk.
* `node[:kafka][:log][:retention_hours]` - The minimum age of a log file to be eligible for
  deletetion.
* `node[:kafka][:log][:retention_bytes]` - A size-based retention policy for logs. Segments
  are pruned from the log as long as the remaining segments don't drop below
  `log_retention_bytes`.
* `node[:kafka][:log][:segment_bytes]` - The maximum size of a log segment file. When this
  size is reached a new log segment will be created.
* `node[:kafka][:log][:cleanup_interval_mins]` - The interval at which log segments are
  checked to see if they can be deleted according to the retention policies.

#### ZooKeeper attributes
* `node[:kafka][:zookeeper][:connect]` - A list of zookeeper nodes to connect to.
* `node[:kafka][:zookeeper][:timeout]` - Timeout in milliseconds for connecting to ZooKeeper.

#### Metric attributes
* `node[:kafka][:metrics][:polling_interval]` - Polling interval for metrics.
* `node[:kafka][:metrics][:reporters]` - Metric reporters to be used.

##### CSV metric attributes
* `node[:kafka][:csv_metrics][:dir]` - Directory path for saving metrics.
* `node[:kafka][:csv_metrics][:reporter_enabled]` - Enable/disable CSV metrics reporter.

### zookeeper
The following attributes are used to configure ZooKeeper when using the
`kafka::standalone` recipe, see below for further explanation.

* `node[:zookeeper][:data_dir]` - Path where to store ZooKeeper data.
* `node[:zookeeper][:log_dir]` - Where to store ZooKeeper logs.
* `node[:zookeeper][:port]` - Port for ZooKeeper to listen for incoming connections.
* `node[:zookeeper][:max_client_connections]` - Maximum number of connections per client.
* `node[:zookeeper][:jmx_port]` - JMX port for ZooKeeper.

## Recipes
This section describes the different recipes that exists, and how to use them.

### default
Includes either `source` or `binary` recipe depending on what
`node[:kafka][:install_method]` is set to (`:source, :binary`).

### configure
Creates necessary directories for installing Kafka, as well as configuration
files and a quite crude `init.d` script.
This recipe is included by both `kafka::source` and `kafka::binary` recipes.

### source
Downloads, compiles and installs Kafka from the official source releases.
Defaults to using `0.8.0-beta1` as Kafka version.

This recipe will not automatically start/restart Kafka as that is left up to the
user to decide.

### binary
Downloads and installs Kafka from the official binary releases.
Defaults to using `0.8.0-beta1` as Kafka version.

This recipe will not automatically start/restart Kafka as that is left up to the
user to decide.

### standalone
Sets up a standalone ZooKeeper server, using the ZooKeeper version that is
bundled with Kafka.
This recipe does not include `kafka::source` nor `kafka::binary` recipes and
must be specified separately after either `kafka::source` or
`kafka::binary`.

This should not be used in production (Kafka and ZooKeeper should generally not
run on the same machine) and is just useful for testing (i.e. in Vagrant or
other testing environment).

## Known bugs & limitations
* No support for Ubuntu/Debian.
* Not tested with all other RHEL distributions.
* No support for per-topic overrides for `node[:kafka][:log][:flush_interval_ms]`.
* Not sure if all configuration parameters for Kafka are supported at this time.

## License and author
Copyright :: 2013 Mathias Söderberg

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
