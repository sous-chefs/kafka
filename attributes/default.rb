#
# Cookbook Name:: kafka
# Attributes:: default
#

#
# Version of Kafka to install.
default.kafka.version = '0.8.1.1'

#
# Base URL for Kafka releases. The recipes will a download URL using the
# `base_url`, `version` and `scala_version` attributes.
default.kafka.base_url = 'https://archive.apache.org/dist/kafka'

#
# SHA-256 checksum of the archive to download, used by Chef's `remote_file`
# resource.
default.kafka.checksum = 'cb141c1d50b1bd0d741d68e5e21c090341d961cd801e11e42fb693fa53e9aaed'

#
# MD5 checksum of the archive to download, which will be used to validate that
# the "correct" archive has been downloaded.
default.kafka.md5_checksum = '7541ed160f1b3aa1a5334d4e782ba4d3'

#
# Scala version of Kafka.
default.kafka.scala_version = '2.9.2'

#
# Decides how to install Kafka, valid values are currently :binary and :source.
default.kafka.install_method = :binary

#
# Directory where to install Kafka.
default.kafka.install_dir = '/opt/kafka'

#
# Directory where the downloaded archive will be extracted to, and possibly
# compiled in.
default.kafka.build_dir = ::File.join(node.kafka.install_dir, 'build')

#
# Directory where to keep Kafka configuration files.
default.kafka.config_dir = ::File.join(node.kafka.install_dir, 'config')

#
# Directory where to store logs from Kafka.
default.kafka.log_dir = '/var/log/kafka'

#
# JMX port for Kafka.
default.kafka.jmx_port = 9999

#
# User for directories, configuration files and running Kafka.
default.kafka.user = 'kafka'

#
# Group for directories, configuration files and running Kafka.
default.kafka.group = 'kafka'

#
# JVM heap options for Kafka.
default.kafka.heap_opts = '-Xmx1G -Xms1G'

#
# Generic JVM options for Kafka.
default.kafka.generic_opts = nil

#
# JVM Performance options for Kafka.
default.kafka.jvm_performance_opts = '-server -XX:+UseCompressedOops -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+CMSScavengeBeforeRemark -XX:+DisableExplicitGC -Djava.awt.headless=true'

#
# GC log options for Kafka.
default.kafka.gc_log_opts = %(-Xloggc:#{node.kafka.log_dir}/kafka-gc.log -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps)

#
# The type of "init" system to install scripts for. Valid values are currently
# :sysv and :upstart.
default.kafka.init_style = :sysv

#
# Automatically start kafka service.
default.kafka.automatic_start = false

#
# Automatically restart kafka on configuration change.
# This also implies `automatic_start` even if it's set to `false`.
# The reason for this is that I can see the need for automatically starting
# Kafka if it's not running, but not necessarily restart on configuration
# changes.
default.kafka.automatic_restart = false

#
# Id of the (current) Kafka broker being set up. This must be set to a unique
# integer for each broker.
# NOTE: mod the broker id by the largest 32 bit unsigned int to avoid
# Kafka choking on the value when it tries to start up.
default.kafka.broker.broker_id = node.ipaddress.gsub('.', '').to_i % 2**31

# Socket server configuration
#
# The port on which the server accepts client connections.
default.kafka.broker.port = 6667

#
# Hostname of broker. If this is set, it will only bind to this address.
# If this is not set, it will bind to all interfaces, and publish one to ZK.
default.kafka.broker.host_name = node.hostname

#
# A list of directory paths in which Kafka data is stored.
# Each new partition that is created will be placed in the directory which
# currently has the fewest partitions.
default.kafka.broker.log_dirs = []

#
# Root logger configuration.
default.kafka.log4j.root_logger = 'INFO, kafkaAppender'

#
# Appender definitions for various classes.
default.kafka.log4j.appenders = {
  'kafkaAppender' => {
    type: 'org.apache.log4j.DailyRollingFileAppender',
    date_pattern: '"."yyyy-MM-dd',
    file: %(#{node.kafka.log_dir}/kafka.log),
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
  'stateChangeAppender' => {
    type: 'org.apache.log4j.DailyRollingFileAppender',
    date_pattern: '"."yyyy-MM-dd',
    file: %(#{node.kafka.log_dir}/kafka-state-change.log),
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
  'requestAppender' => {
    type: 'org.apache.log4j.DailyRollingFileAppender',
    date_pattern: '"."yyyy-MM-dd',
    file: %(#{node.kafka.log_dir}/kafka-request.log),
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
  'controllerAppender' => {
    type: 'org.apache.log4j.DailyRollingFileAppender',
    date_pattern: '"."yyyy-MM-dd',
    file: %(#{node.kafka.log_dir}/kafka-controller.log),
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
}

#
# Logger definitions.
default.kafka.log4j.loggers = {
  'org.IOItec.zkclient.ZkClient' => {
    level: 'INFO',
  },
  'kafka.network.RequestChannel$' => {
    level: 'WARN',
    appender: 'requestAppender',
    additivity: false,
  },
  'kafka.request.logger' => {
    level: 'WARN',
    appender: 'requestAppender',
    additivity: false,
  },
  'kafka.controller' => {
    level: 'INFO',
    appender: 'controllerAppender',
    additivity: false,
  },
  'state.change.logger' => {
    level: 'INFO',
    appender: 'stateChangeAppender',
    additivity: false,
  },
}
