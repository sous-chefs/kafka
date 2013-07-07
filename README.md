# Description
Installs Kafka 0.8.0-beta1, and probably any higher version, whenever they are
released. Given that they don't change URLs and the like.

Based on the Kafka cookbook released by WebTrends (thanks!), but with a few
notable differences:

* supports both source and binary releases of Kafka 0.8.0-beta1.
* does not depend on runit cookbook.
* does not depend on zookeeper cookbook, thus it will not search for nodes with
  a specific role or such, that is left up to you to decide.
* only tested with a CentOS Vagrant box.

# Requirements
* Java cookbook ~> 1.11.6

# Attributes
This section describes all the attributes that are currently available for
configuration of where to install Kafka and Kafka's configuration. (Having two
consecutive headers without any text between them make me cringe).

## default
The following attributes are used for setting up the 'environment' for Kafka.

* kafka.version - The Kafka version install and use.
* kafka.base\_url - URL for Kafka releases.
* kafka.checksum - MD5 checksum for release to use.
* kafka.scala\_version - Scala version for Kafka.
* kafka.install\_dir - Location for Kafka to be installed.
* kafka.log\_dir - Location for Kafka log4j logs.
* kafka.user - User to use for directories and to run Kafka.
* kafka.group - Group for user defined in bullet point above.
* kafka.log\_level - Log level for Kafka logs (and ZooKeeper, for further
  information see below).
* kafka.jmx\_port - JMX port for Kafka.

## kafka
The following attributes are used for the Kafka broker configuration and are
divided into logical sections according to the official Kafka configuration.

### General broker configuration attributes
* kafka.broker\_id - The id of the broker. This must be set to a unique integer
  for each broker. If not set, it will default to the machine's ip address
  (without the dots).
* kafka.host\_name - Host name the broker will advertise. If not set, Kafka will
  use the host name returned from java.net.InetAddress.getCanonicalHostName(),
  which might not be what you want.
* kafka.port - The port Kafka will listen on for incoming requests.
* kafka.network\_threads - The number of threads handling network requests.
* kafka.io\_threads - The number of threads doing disk I/O.
* kafka.num\_partitions - The number of logical partitions per topic per server.
  More partitions allow greater parallelism for consumption, but also mean more
  files.

### Socket server attributes
* kafka.socket.send\_buffer\_bytes - The send buffer (SO\_SNDBUF) used by the
  socket server.
* kafka.socket.receive\_buffer\_bytes - The receive buffer (SO\_RCVBUF) used by
  the socket server.
* kafka.socket.request\_max\_bytes - The maximum size of a request that the
  socket server will accept (protection against OOM).

### Log and flush policy attributes
* kafka.log.dirs - The directory under which Kafka will store log files.
* kafka.log.flush\_interval\_messages - The number of messages to accept before
  forcing a flush of data to disk.
* kafka.log.flush\_interval\_ms - The maximum amount of time a message can sit
  in a log before Kafka forces a flush to disk.
* kafka.log.retention\_hours - The minimum age of a log file to be eligible for
  deletetion.
* kafka.log.retention\_bytes - A size-based retention policy for logs. Segments
  are pruned from the log as long as the remaining segments don't drop below
  log\_retention\_bytes.
* kafka.log.segment\_bytes - The maximum size of a log segment file. When this
  size is reached a new log segment will be created.
* kafka.log.cleanup\_interval\_mins - The interval at which log segments are
  checked to see if they can be deleted according to the retention policies.

### ZooKeeper attributes
* kafka.zookeeper.connect - A list of zookeeper nodes to connect to.
* kafka.zookeeper.timeout - Timeout in milliseconds for connection to ZooKeeper.

### Metric attributes
* kafka.metrics.polling\_interval - Polling interval for metrics.
* kafka.metrics.reporters - Metric reporters to be used.

#### CSV metric attributes
* kafka.csv\_metrics.dir - Directory path for saving metrics.
* kafka.csv\_metrics.reporter\_enabled - Enable/disable CSV metrics reporter.

## zookeeper
The following attributes are used to configure ZooKeeper when using the
``kafka::standalone`` recipe, see below for further information.

* zookeeper.data\_dir - Path where to store ZooKeeper data.
* zookeeper.log\_dir - Where to store ZooKeeper logs.
* zookeeper.port - Port for ZooKeeper to listen for incoming connections.
* zookeeper.max\_client\_connections - Maximum number of connections per client.
* zookeeper.jmx\_port - JMX port for ZooKeeper.

# Recipes
This section describes the different recipes that exists, and how to use them.

## default
Sets up ``broker_id`` and ``host_name``, and creates necessary directories for
installing Kafka, as well as a quite crude ``init.d`` script.
This recipe is included by both ``kafka::source`` and ``kafka::binary`` recipes.

## source
Downloads, compiles and installs Kafka from the official source releases.
Defaults to using ``0.8.0-beta1`` as Kafka version.

This recipe will not automatically start/restart Kafka as that is left up to the
user to decide.

## binary
Downloads and installs Kafka from the official binary releases.
Defaults to using ``0.8.0-beta1`` as Kafka version.

This recipe will not automatically start/restart Kafka as that is left up to the
user to decide.

## standalone
Sets up a standalone ZooKeeper server, using the ZooKeeper version that is
bundled with Kafka.
This recipe does not include ``kafka::source`` nor ``kafka::binary`` recipes and
must be specified separately after either ``kafka::source`` or
``kafka::binary``.

This should not be used in production (Kafka and ZooKeeper should generally not
run on the same machine) and is just useful for testing (i.e. in Vagrant or
other testing environment).

# License and author:
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

<!---
Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add\_component\_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github
-->
