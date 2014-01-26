# kafka cookbook

[![Build Status](https://travis-ci.org/mthssdrbrg/kafka-cookbook.png?branch=master)](https://travis-ci.org/mthssdrbrg/kafka-cookbook)

Installs Kafka `0.8.0`, and probably any newer versions.

Based on the Kafka cookbook released by WebTrends (thanks!), but with a few
notable differences:

* supports both source and binary releases (of Kafka `0.8.0`).
* does not depend on runit cookbook.
* does not depend on zookeeper cookbook, thus it will not search for nodes with
  a specific role or such, that is left up to you to decide.
* only tested on Vagrant boxes.
* intended to be used by wrapper cookbooks.

## Requirements

This cookbook does not depend on any specific cookbooks, but it requires that
java is installed on the system, thus the `java` cookbook is recommended.

Ruby 1.9.3+ and Chef 11.8.2+.

### Platform

* Debian 7.2.0
* Ubuntu 13.10
* CentOS 6.5
* Fedora 18

Might work on other platforms / releases, but these are the ones that are
included in `.kitchen.yml`, so YMMV.
For some reason the `java` cookbook does not set the correct java path on Fedora
19 and 20, which is why Fedora 18 is used rather than the 19 or 20 releases.

## Attributes

This section describes all the attributes that are currently available for
configuration of where and how to install Kafka, as well as broker
configuration.

### default

The following attributes are used for setting up the environment for Kafka, as
well as configuring Kafka.

* `node[:kafka][:version]` - The Kafka version to install and use.
* `node[:kafka][:base_url]` - Base URL for Kafka releases.
* `node[:kafka][:checksum]` - SHA-256 checksum to use when downloading
  release.
* `node[:kafka][:md5_checksum]` - MD5 checksum to use when validating
  downloaded release.
* `node[:kafka][:scala_version]` - Scala version for Kafka.
* `node[:kafka][:install_method]` - Decides how to install Kafka, by binary or
  from source. Defaults to `:binary`.
* `node[:kafka][:install_dir]` - Location for Kafka to be installed.
* `node[:kafka][:config_dir]` - Location for Kafka configuration files.
* `node[:kafka][:log_dir]` - Location for Kafka log4j logs.
* `node[:kafka][:log4j_config]` - Name of log4j configuration file (should
  include extension as well). Will use `log4j.properties` by default.
* `node[:kafka][:log_level]` - Log level for Kafka logs (and ZooKeeper, for further
  information see below).
* `node[:kafka][:config]` - Name of configuration file for Kafka (should
  include extension as well). Will use `server.properties` by default.
* `node[:kafka][:jmx_port]` - JMX port for Kafka.
* `node[:kafka][:user]` - User to use for directories and configuration files.
* `node[:kafka][:group]` - Group for user defined above.
* `node[:kafka][:heap_opts]` - JVM heap options for the Kafka broker.
* `node[:kafka][:generic_opts]` - Generic JVM options for the Kafka broker.

#### General broker configuration

* `node[:kafka][:broker_id]` - The id of the broker. This must be set to a unique integer
  for each broker. If not set, it will default to using the machine's ip address
  (without the dots).
* `node[:kafka][:message_max_bytes]` - The maximum size of message that the server can receive.
* `node[:kafka][:num_network_threads]` - The number of network threads that the server uses for handling network requests.
* `node[:kafka][:num_io_threads]` - The number of io threads that the server uses for carrying out network requests.
* `node[:kafka][:queued_max_requests]` - The number of queued requests allowed before blocking the network threads.

#### Socket server configuration

* `node[:kafka][:port]` - The port Kafka will listen on for incoming requests.
  Defaults to 6667.
* `node[:kafka][:host_name]` - Hostname of broker. If this is set, it will only bind to this address.
  If this is not set, it will bind to all interfaces, and publish one to ZK.
* `node[:kafka][:socket][:send_buffer_bytes]` - The send buffer (`SO_SNDBUF`) used by the
  socket server.
* `node[:kafka][:socket][:receive_buffer_bytes]` - The receive buffer (`SO_RCVBUF`) used by
  the socket server.
* `node[:kafka][:socket][:request_max_bytes]` - The maximum size of a request that the
  socket server will accept (protection against out of memory).

#### Log configuration

* `node[:kafka][num_partitions]` - The default number of log partitions per topic.
* `node[:kafka][:log][:dirs]` - The directories in which the log data is kept.
* `node[:kafka][:log][:segment_bytes]` - The maximum size of a log segment file. When this
  size is reached a new log segment will be created.
* `node[:kafka][:log][:segment_bytes_per_topic]` - The maximum size of a single
  log segment file for some specific topic. Should be a hash of topic -> max
  size mappings.
* `node[:kafka][:log][:roll_hours]` - The maximum time before a new log segment is rolled out.
* `node[:kafka][:log][:roll_hours_per_topic]` - The maximum time before a new
  log segment is rolled out for specific topics. Should be a hash of topic ->
  hours mappings.
* `node[:kafka][:log][:retention_hours]` - The number of hours to keep a log file before deleting it.
* `node[:kafka][:log][:retention_hours_per_topic]` - The number of hours to keep
  a log file for specific topics. Should be a hash of topic -> hours mappings.
* `node[:kafka][:log][:retention_bytes]` - A size-based retention policy for logs. Segments
  are pruned from the log as long as the remaining segments don't drop below
  `log_retention_bytes`.
* `node[:kafka][:log][:retention_bytes_per_topic]` - The maximum size of the log
  for specific topics. Should be a hash of topic -> max size mappings.
* `node[:kafka][:log][:cleanup_interval_mins]` - The frequency in minutes that
  the log cleaner checks whether any log is eligible for deletion.
* `node[:kafka][:log][:index_size_max_bytes]` - The maximum size in bytes of the offset index.
* `node[:kafka][:log][:index_interval_bytes]` - The interval with which we add an entry to the offset index.
* `node[:kafka][:log][:flush_interval_messages]` - The number of messages accumulated on a log partition
  before messages are flushed to disk.
* `node[:kafka][:log][:flush_interval_ms]` - The maximum time in ms that a message in any topic is
  kept in memory before flushed to disk.
* `node[:kafka][:log][:flush_interval_ms_per_topic]` - The maximum time in ms
  that a message in specific topics is kept in memory before flushed to disk.
  Should be a hash of topic -> interval mappings.
* `node[:kafka][:log][:flush_scheduler_interval_ms]` - The frequency in ms that
  the log flusher checks whether any log needs to be flushed to disk.
* `node[:kafka][:auto_create_topics]` - Enable auto creation of topics on the
  broker.

#### Replication configuration

* `node[:kafka][:controller][:socket_timeout_ms]` - The socket timeout for controller-to-broker channels.
* `node[:kafka][:controller][:message_queue_size]` - The buffer size for controller-to-broker-channels.
* `node[:kafka][:default_replication_factor]` - Default replication factor for automatically created topics.
* `node[:kafka][:replica][:lag_time_max_ms]` - If a follower hasn't sent any fetch requests during this time,
  the leader will remove the follower from ISR.
* `node[:kafka][:replica][:lag_max_messages]` - If the lag in messages between a leader and a follower exceeds this number,
  the leader will remove the follower from ISR.
* `node[:kafka][:replica][:socket_timeout_ms]` - The socket timeout for network requests.
* `node[:kafka][:replica][:socket_receive_buffer_bytes]` - The socket receive buffer for network requests.
* `node[:kafka][:replica][:fetch_max_bytes]` - The number of bytes of messages to attempt to fetch.
* `node[:kafka][:replica][:fetch_min_bytes]` - Minimum bytes expected for each fetch response.
  If not enough bytes, wait up to `fetch_wait_max_ms`.
* `node[:kafka][:replica][:fetch_wait_max_ms]` - Max wait time for each fetcher request issued by follower replicas.
* `node[:kafka][:num_replica_fetchers]` - Number of fetcher threads used to replicate messages from a source broker.
  Increasing this value can increase the degree of I/O parallelism in the follower broker.
* `node[:kafka][:replica][:high_watermark_checkpoint_interval_ms]` - The frequency with which the high watermark is saved out to disk.
* `node[:kafka][:fetch][:purgatory_purge_interval_requests]` - the purge interval (in number of requests) of the fetch request purgatory.
* `node[:kafka][:producer][:purgatory_purge_interval_requests]` - the purge interval (in number of requests) of the producer request purgatory.

#### Controlled shutdown configuration

* `node[:kafka][:controlled_shutdown][:max_retries]` - Controlled shutdown can fail for multiple reasons.
  This determines the number of retries when such failure happens.
* `node[:kafka][:controlled_shutdown][:retry_backoff_ms]` - Before each retry, the system needs time to
  recover from the state that caused the previous failure (Controller fail over, replica lag etc).
  This config determines the amount of time to wait before retrying.
* `node[:kafka][:controlled_shutdown][:enabled]` - Enable controlled shutdown of the server.

#### ZooKeeper configuration

* `node[:kafka][:zookeeper][:connect]` - A list of ZooKeeper nodes to connect to.
* `node[:kafka][:zookeeper][:connection_timeout_ms]` - The max time that the client waits to establish a connection to ZooKeeper.
* `node[:kafka][:zookeeper][:session_timeout_ms]` - ZooKeeper session timeout.
* `node[:kafka][:zookeeper][:sync_time_ms]` - How far a ZK follower can be behind a ZK leader.

### zookeeper

The following attributes are used to configure ZooKeeper when using the
`kafka::zookeeper` recipe, see below for further explanation.

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

### source

Downloads, compiles and installs Kafka from the official source releases.
Defaults to using `0.8.0` as Kafka version.

### binary

Downloads and installs Kafka from the official binary releases.
Defaults to using `0.8.0` as Kafka version.

### zookeeper

Sets up a standalone ZooKeeper server, using the ZooKeeper version that is
bundled with Kafka.

This should not be used in production (Kafka and ZooKeeper should generally not
run on the same machine) and is just useful for testing (i.e. in Vagrant or
other testing environment).

## Copyright

Copyright :: 2013-2014 Mathias Söderberg

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
