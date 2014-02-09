#
# Cookbook Name:: kafka
# Attributes:: default
#

default[:kafka][:version] = '0.8.0'
default[:kafka][:base_url] = 'https://dist.apache.org/repos/dist/release/kafka'
default[:kafka][:checksum] = nil
default[:kafka][:md5_checksum] = nil
default[:kafka][:scala_version] = nil
default[:kafka][:install_method] = :binary
default[:kafka][:install_dir] = '/opt/kafka'
default[:kafka][:build_dir] = ::File.join(node[:kafka][:install_dir], 'build')
default[:kafka][:config_dir] = ::File.join(node[:kafka][:install_dir], 'config')
default[:kafka][:log_dir] = '/var/log/kafka'
default[:kafka][:log4j_config] = 'log4j.properties'
default[:kafka][:log_level] = 'INFO'
default[:kafka][:config] = 'server.properties'
default[:kafka][:jmx_port] = 9999
default[:kafka][:user] = 'kafka'
default[:kafka][:group] = 'kafka'
default[:kafka][:heap_opts] = '-Xmx1G -Xms1G'
default[:kafka][:generic_opts] = nil
default[:kafka][:init_style] = :sysv

# General configuration
default[:kafka][:broker_id] = node[:ipaddress].gsub('.', '')
default[:kafka][:message_max_bytes] = 1_000_000
default[:kafka][:num_network_threads] = 3
default[:kafka][:num_io_threads] = 8
default[:kafka][:queued_max_requests] = 500

# Socket server configuration
default[:kafka][:port] = 6667
default[:kafka][:host_name] = node[:hostname]
default[:kafka][:socket][:send_buffer_bytes] = 100 * 1024
default[:kafka][:socket][:receive_buffer_bytes] = 100 * 1024
default[:kafka][:socket][:request_max_bytes] = 100 * 1024 * 1024

# Log configuration
default[:kafka][:num_partitions] = 1
default[:kafka][:log][:dirs] = ['/tmp/kafka-logs']
default[:kafka][:log][:segment_bytes] = 1 * 1024 * 1024 * 1024
default[:kafka][:log][:segment_bytes_per_topic] = {}
default[:kafka][:log][:roll_hours] = 24 * 7
default[:kafka][:log][:roll_hours_per_topic] = {}
default[:kafka][:log][:retention_hours] = 24 * 7
default[:kafka][:log][:retention_hours_per_topic] = {}
default[:kafka][:log][:retention_bytes] = -1
default[:kafka][:log][:retention_bytes_per_topic] = {}
default[:kafka][:log][:cleanup_interval_mins] = 10
default[:kafka][:log][:index_size_max_bytes] = 10 * 1024 * 1024
default[:kafka][:log][:index_interval_bytes] = 4096
default[:kafka][:log][:flush_interval_messages] = 10_000
default[:kafka][:log][:flush_interval_ms] = 3000
default[:kafka][:log][:flush_interval_ms_per_topic] = {}
default[:kafka][:log][:flush_scheduler_interval_ms] = node[:kafka][:log][:flush_interval_ms]
default[:kafka][:auto_create_topics] = true

# Replication configuration
default[:kafka][:controller][:socket_timeout_ms] = 30_000
default[:kafka][:controller][:message_queue_size] = 10
default[:kafka][:default_replication_factor] = 1
default[:kafka][:replica][:lag_time_max_ms] = 10_000
default[:kafka][:replica][:lag_max_messages] = 4000
default[:kafka][:replica][:socket_timeout_ms] = 30 * 1000
default[:kafka][:replica][:socket_receive_buffer_bytes] = 64 * 1024
default[:kafka][:replica][:fetch_max_bytes] = 1024 * 1024
default[:kafka][:replica][:fetch_wait_max_ms] = 500
default[:kafka][:replica][:fetch_min_bytes] = 1
default[:kafka][:num_replica_fetchers] = 1
default[:kafka][:replica][:high_watermark_checkpoint_interval_ms] = 5000
default[:kafka][:fetch][:purgatory_purge_interval_requests] = 10_000
default[:kafka][:producer][:purgatory_purge_interval_requests] = 10_000

# Controlled shutdown configuration
default[:kafka][:controlled_shutdown][:max_retries] = 3
default[:kafka][:controlled_shutdown][:retry_backoff_ms] = 5000
default[:kafka][:controlled_shutdown][:enabled] = false

# ZooKeeper configuration
default[:kafka][:zookeeper][:connect] = []
default[:kafka][:zookeeper][:connection_timeout_ms] = 6000
default[:kafka][:zookeeper][:session_timeout_ms] = 6000
default[:kafka][:zookeeper][:sync_time_ms] = 2000
