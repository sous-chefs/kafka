#
# Cookbook Name:: kafka
# Attributes:: default
#

#
# Version of Kafka to install.
default[:kafka][:version] = '0.8.1.1'

#
# Base URL for Kafka releases. The recipes will a download URL using the
# `base_url`, `version` and `scala_version` attributes.
default[:kafka][:base_url] = 'https://archive.apache.org/dist/kafka'

#
# SHA-256 checksum of the archive to download, used by Chef's `remote_file`
# resource.
default[:kafka][:checksum] = 'cb141c1d50b1bd0d741d68e5e21c090341d961cd801e11e42fb693fa53e9aaed'

#
# MD5 checksum of the archive to download, which will be used to validate that
# the "correct" archive has been downloaded.
default[:kafka][:md5_checksum] = '7541ed160f1b3aa1a5334d4e782ba4d3'

#
# Scala version of Kafka.
default[:kafka][:scala_version] = '2.9.2'

#
# Decides how to install Kafka, valid values are currently :binary and :source.
default[:kafka][:install_method] = :binary

#
# Directory where to install Kafka.
default[:kafka][:install_dir] = '/opt/kafka'

#
# Directory where the downloaded archive will be extracted to, and possibly
# compiled in.
default[:kafka][:build_dir] = ::File.join(node[:kafka][:install_dir], 'build')

#
# Directory where to keep Kafka configuration files.
default[:kafka][:config_dir] = ::File.join(node[:kafka][:install_dir], 'config')

#
# Directory where to store logs from Kafka.
default[:kafka][:log_dir] = '/var/log/kafka'

#
# Name of the Log4J configuration file that Kafka (and ZooKeeper) will use.
default[:kafka][:log4j_config] = 'log4j.properties'

#
# Log level for Log4J.
default[:kafka][:log_level] = 'INFO'

#
# Name of main configuration file for Kafka.
default[:kafka][:config] = 'server.properties'

#
# JMX port for Kafka.
default[:kafka][:jmx_port] = 9999

#
# User for directories, configuration files and running Kafka.
default[:kafka][:user] = 'kafka'

#
# Group for directories, configuration files and running Kafka.
default[:kafka][:group] = 'kafka'

#
# JVM heap options for Kafka.
default[:kafka][:heap_opts] = '-Xmx1G -Xms1G'

#
# Generic JVM options for Kafka.
default[:kafka][:generic_opts] = nil

#
# The type of "init" system to install scripts for. Valid values are currently
# :sysv and :upstart.
default[:kafka][:init_style] = :sysv

# General configuration
#
# Id of the (current) Kafka broker being set up. This must be set to a unique
# integer for each broker.
# NOTE: mod the broker id by the largest 32 bit unsigned int to avoid
# Kafka choking on the value when it tries to start up.
default[:kafka][:broker_id] = node[:ipaddress].gsub('.', '').to_i % 2**31

#
# The maximum size of a message that the server can receive.
# It is important that this property be in sync with the maximum fetch size
# your consumers use or else an unruly producer will be able to publish messages
# too large for consumers to consume.
default[:kafka][:message_max_bytes] = nil

#
# The number of network threads that the server uses for handling network
# requests.
default[:kafka][:num_network_threads] = nil

#
# The number of I/O threads that the server uses for executing requests.
default[:kafka][:num_io_threads] = nil

#
# The number of threads to use for various background processing tasks such as
# file deletion.
#
# NOTE: only for versions > 0.8.0
default[:kafka][:background_threads] = nil

#
# The number of requests that can be queued up for processing by the I/O threads
# before the network threads stop reading in new requests.
default[:kafka][:queued_max_requests] = nil

# Socket server configuration
#
# The port on which the server accepts client connections.
default[:kafka][:port] = 6667

#
# Hostname of broker. If this is set, it will only bind to this address.
# If this is not set, it will bind to all interfaces, and publish one to ZK.
default[:kafka][:host_name] = node[:hostname]

#
# If this is set this is the hostname that will be given out to producers,
# consumers, and other brokers to connect to.
#
# NOTE: only for versions > 0.8.0
default[:kafka][:advertised_host_name] = nil

#
# The port to give out to producers, consumers, and other brokers to use in
# establishing connections.
# This only needs to be set if this port is different from the port the server
# should bind to.
#
# NOTE: only for versions > 0.8.0
default[:kafka][:advertised_port] = nil

#
# The SO_SNDBUFF buffer the server prefers for socket connections.
default[:kafka][:socket][:send_buffer_bytes] = nil

#
# The SO_RCVBUFF buffer the server prefers for socket connections.
default[:kafka][:socket][:receive_buffer_bytes] = nil

#
# The maximum request size the server will allow.
# This prevents the server from running out of memory and should be smaller
# than the Java heap size.
default[:kafka][:socket][:request_max_bytes] = nil

# Log configuration
#
# The default number of partitions per topic if a partition count isn't given
# at topic creation time.
default[:kafka][:num_partitions] = nil
default[:kafka][:log][:dirs] = []

#
# The log for a topic partition is stored as a directory of segment files.
# This setting controls the size to which a segment file will grow before a new
# segment is rolled over in the log.
default[:kafka][:log][:segment_bytes] = nil

#
# Segment bytes per topic, configured as an Hash with topics as keys and
# integers as values.
#
# NOTE: only for 0.8.0
default[:kafka][:log][:segment_bytes_per_topic] = {}

#
# This setting will force Kafka to roll a new log segment even if the
# log.segment.bytes size has not been reached.
default[:kafka][:log][:roll_hours] = nil

#
# Roll hours per topic, configured as an Hash with topics as keys and
# integers as values.
#
# NOTE: only for 0.8.0
default[:kafka][:log][:roll_hours_per_topic] = {}

#
# The number of minutes to keep a log segment before it is deleted, i.e. the
# default data retention window for all topics.
#
# NOTE: only for versions > 0.8.0
default[:kafka][:log][:retention_minutes] = nil

#
# The number of hours to keep a log segment before it is deleted, i.e. the
# default data retention window for all topics.
#
# NOTE: only for 0.8.0
default[:kafka][:log][:retention_hours] = nil

#
# Retention hours per topic, configured as an Hash with topics as keys and
# integers as values.
#
# NOTE: only for 0.8.0
default[:kafka][:log][:retention_hours_per_topic] = {}

#
# The amount of data to retain in the log for each topic-partitions.
default[:kafka][:log][:retention_bytes] = nil

#
# Retention bytes per topic, configured as an Hash with topics as keys and
# integers as values.
#
# NOTE: only for 0.8.0
default[:kafka][:log][:retention_bytes_per_topic] = {}

#
# The period with which we check whether any log segment is eligible for
# deletion to meet the retention policies.
#
# NOTE: only for versions > 0.8.0
default[:kafka][:log][:retention_check_interval_ms] = nil

#
# The frequency in minutes that the log cleaner checks whether any log segment
# is eligible for deletion to meet the retention policies.
#
# NOTE: only for 0.8.0
default[:kafka][:log][:cleanup_interval_mins] = nil

#
# The maximum size in bytes allowed for the offset index for each log segment.
default[:kafka][:log][:index_size_max_bytes] = nil

#
# The byte interval at which we add an entry to the offset index.
default[:kafka][:log][:index_interval_bytes] = nil

#
# The number of messages written to a log partition before forcing a fsync of
# the log.
default[:kafka][:log][:flush_interval_messages] = nil

#
# The maximum time between fsync calls on the log.
# If used in conjuction with `log.flush.interval.messages` the log will be
# flushed when either criteria is met.
default[:kafka][:log][:flush_interval_ms] = nil

#
# Flush interval (ms) per topic, configured as an Hash with topics as keys and
# integers as values.
#
# NOTE: only for 0.8.0
default[:kafka][:log][:flush_interval_ms_per_topic] = {}

#
# The frequency in ms that the log flusher checks whether any log is eligible
# to be flushed to disk.
default[:kafka][:log][:flush_scheduler_interval_ms] = nil

#
# Enable auto creation of topic on the server.
# If this is set to true then attempts to produce, consume, or fetch metadata
# for a non-existent topic will automatically create it with the default
# replication factor and number of partitions.
default[:kafka][:auto_create_topics] = nil

#
# The period of time we hold log files around after they are removed from the
# index.
# This period of time allows any in-progress reads to complete uninterrupted
# without locking.
default[:kafka][:log][:delete_delay_ms] = nil

#
# The frequency with which we checkpoint the last flush point for logs for
# recovery.
default[:kafka][:log][:flush_offset_checkpoint_interval_ms] = nil

#
# A string that is either "delete" or "compact".
# This string designates the retention policy to use on old log segments.
# The default policy ("delete") will discard old segments when their retention
# time or size limit has been reached.
# The "compact" setting will enable log compaction on the topic.
#
# NOTE: only for versions > 0.8.0
default[:kafka][:log][:cleanup_policy] = nil

# Log cleaner configuration
#
# NOTE: the following attributes only applies for versions > 0.8.0.
#
# This configuration must be set to true for log compaction to run.
default[:kafka][:log][:cleaner_enable] = nil

#
# The number of threads to use for cleaning logs in log compaction.
default[:kafka][:log][:cleaner_threads] = nil

#
# The maximum amount of I/O the log cleaner can do while performing log compaction.
# This setting allows setting a limit for the cleaner to avoid impacting live request serving.
default[:kafka][:log][:cleaner_io_max_bytes_per_second] = nil

#
# The size of the buffer the log cleaner uses for indexing and deduplicating logs
# during cleaning.
# Larger is better provided you have sufficient memory.
default[:kafka][:log][:cleaner_dedupe_buffer_size] = nil

#
# The size of the I/O chunk used during log cleaning.
# You probably don't need to change this.
default[:kafka][:log][:cleaner_io_buffer_size] = nil

#
# The load factor of the hash table used in log cleaning.
# You probably don't need to change this.
default[:kafka][:log][:cleaner_io_buffer_load_factor] = nil

#
# The interval between checks to see if any logs need cleaning.
default[:kafka][:log][:cleaner_backoff_ms] = nil

#
# This configuration controls how frequently the log compactor will attempt to
# clean the log (assuming log compaction is enabled).
# A higher ratio will mean fewer, more efficient cleanings but will mean more
# wasted space in the log.
default[:kafka][:log][:cleaner_min_cleanable_ratio] = nil

#
# The amount of time to retain delete tombstone markers for log compacted topics.
default[:kafka][:log][:cleaner_delete_retention_ms] = nil

# Replication configuration
#
# The socket timeout for commands from the partition management controller to
# the replicas.
default[:kafka][:controller][:socket_timeout_ms] = nil

#
# The buffer size for controller-to-broker-channels.
default[:kafka][:controller][:message_queue_size] = nil

#
# The default replication factor for automatically created topics.
default[:kafka][:default_replication_factor] = nil

#
# If a follower hasn't sent any fetch requests for this window of time, the
# leader will remove the follower from ISR (in-sync replicas) and treat it as
# dead.
default[:kafka][:replica][:lag_time_max_ms] = nil

#
# If a replica falls more than this many messages behind the leader, the
# leader will remove the follower from ISR and treat it as dead.
default[:kafka][:replica][:lag_max_messages] = nil

#
# The socket timeout for network requests to the leader for replicating data.
default[:kafka][:replica][:socket_timeout_ms] = nil

#
# The socket receive buffer for network requests to the leader for replicating
# data.
default[:kafka][:replica][:socket_receive_buffer_bytes] = nil

#
# The number of byes of messages to attempt to fetch for each partition in the
# fetch requests the replicas send to the leader.
default[:kafka][:replica][:fetch_max_bytes] = nil

#
# The maximum amount of time to wait time for data to arrive on the leader in
# the fetch requests sent by the replicas to the leader.
default[:kafka][:replica][:fetch_wait_max_ms] = nil

#
# Minimum bytes expected for each fetch response for the fetch requests from
# the replica to the leader.
default[:kafka][:replica][:fetch_min_bytes] = nil

#
# Number of threads used to replicate messages from leaders.
default[:kafka][:num_replica_fetchers] = nil

#
# The frequency with which each replica saves its high watermark to disk to
# handle recovery.
default[:kafka][:replica][:high_watermark_checkpoint_interval_ms] = nil

#
# The purge interval (in number of requests) of the fetch request purgatory.
default[:kafka][:fetch_purgatory_purge_interval_requests] = nil

#
# The purge interval (in number of requests) of the producer request purgatory.
default[:kafka][:producer_purgatory_purge_interval_requests] = nil

# Controlled shutdown configuration
#
# Enable controlled shutdown of the broker.
# If enabled, the broker will move all leaders on it to some other brokers
# before shutting itself down.
# This reduces the unavailability window during shutdown.
default[:kafka][:controlled_shutdown][:enabled] = nil

#
# Number of retries to complete the controlled shutdown successfully before
# executing an unclean shutdown.
default[:kafka][:controlled_shutdown][:max_retries] = nil

#
# Backoff time between shutdown retries.
default[:kafka][:controlled_shutdown][:retry_backoff_ms] = nil

# Leader related configuration
#
# NOTE: the following attributes only applies for versions > 0.8.0.
#
# If this is enabled the controller will automatically try to balance
# leadership for partitions among the brokers by periodically returning
# leadership to the "preferred" replica for each partition if it is available.
default[:kafka][:auto_leader_rebalance_enable] = nil

#
# The percentage of leader imbalance allowed per broker.
# The controller will rebalance leadership if this ratio goes above the
# configured value per broker.
default[:kafka][:leader][:imbalance_per_broker_percentage] = nil

#
# The frequency with which to check for leader imbalance.
default[:kafka][:leader][:imbalance_check_interval_seconds] = nil

# Consumer offset management configuration (> v0.8.0 configuration options)
#
# The maximum amount of metadata to allow clients to save with their offsets.
default[:kafka][:offset_metadata_max_bytes] = nil

# ZooKeeper configuration
#
# Specifies the zookeeper connection string in the form `hostname:port`, where
# hostname and port are the host and port for a node in your zookeeper cluster.
default[:kafka][:zookeeper][:connect] = []

#
# The maximum amount of time that the client waits to establish a connection to
# ZooKeeper.
default[:kafka][:zookeeper][:connection_timeout_ms] = nil

#
# ZooKeeper session timeout.
# If the server fails to heartbeat to zookeeper within this period of time it
# is considered dead.
default[:kafka][:zookeeper][:session_timeout_ms] = nil

#
# How far a ZK follower can be behind a ZK leader.
# NOTE: not actually sure why this is in the Kafka documentation though.
default[:kafka][:zookeeper][:sync_time_ms] = nil

#
# ZooKeeper also allows you to add a "chroot" path which will make all Kafka
# data for this cluster appear under a particular path.
# This is a way to setup multiple Kafka clusters or other applications on the
# same zookeeper cluster.
default[:kafka][:zookeeper][:path] = nil
