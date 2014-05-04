#
# Cookbook Name:: kafka
# Attributes:: default
#

default[:kafka][:version] = '0.8.1.1'
default[:kafka][:base_url] = 'https://archive.apache.org/dist/kafka'
default[:kafka][:checksum] = nil
default[:kafka][:md5_checksum] = nil
default[:kafka][:scala_version] = '2.9.2'
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
# Mod the broker id by the largest 32 bit unsigned int to avoid kafka
# choking on the value when it tries to start up.
default[:kafka][:broker_id] = node[:ipaddress].gsub('.', '').to_i % 2**31
default[:kafka][:message_max_bytes] = nil
default[:kafka][:num_network_threads] = nil
default[:kafka][:num_io_threads] = nil
default[:kafka][:background_threads] = nil
default[:kafka][:queued_max_requests] = nil

# Socket server configuration
default[:kafka][:port] = 6667
default[:kafka][:host_name] = node[:hostname]
default[:kafka][:advertised_host_name] = nil
default[:kafka][:advertised_port] = nil
default[:kafka][:socket][:send_buffer_bytes] = nil
default[:kafka][:socket][:receive_buffer_bytes] = nil
default[:kafka][:socket][:request_max_bytes] = nil

# Log configuration
default[:kafka][:num_partitions] = nil
default[:kafka][:log][:dirs] = []
default[:kafka][:log][:segment_bytes] = nil
default[:kafka][:log][:segment_bytes_per_topic] = {}
default[:kafka][:log][:roll_hours] = nil
default[:kafka][:log][:roll_hours_per_topic] = {}
default[:kafka][:log][:retention_mins] = nil
default[:kafka][:log][:retention_hours] = nil
default[:kafka][:log][:retention_hours_per_topic] = {}
default[:kafka][:log][:retention_bytes] = nil
default[:kafka][:log][:retention_bytes_per_topic] = {}
default[:kafka][:log][:retention_check_interval_ms] = nil
default[:kafka][:log][:cleanup_interval_mins] = nil
default[:kafka][:log][:index_size_max_bytes] = nil
default[:kafka][:log][:index_interval_bytes] = nil
default[:kafka][:log][:flush_interval_messages] = nil
default[:kafka][:log][:flush_interval_ms] = nil
default[:kafka][:log][:flush_interval_ms_per_topic] = {}
default[:kafka][:log][:flush_scheduler_interval_ms] = nil
default[:kafka][:auto_create_topics] = nil

# Log cleaner configuration
default[:kafka][:log][:cleaner_enable] = nil
default[:kafka][:log][:cleaner_threads] = nil
default[:kafka][:log][:cleaner_io_max_bytes_per_second] = nil
default[:kafka][:log][:cleaner_dedupe_buffer_size] = nil
default[:kafka][:log][:cleaner_io_buffer_size] = nil
default[:kafka][:log][:cleaner_io_buffer_load_factor] = nil
default[:kafka][:log][:cleaner_backoff_ms] = nil
default[:kafka][:log][:cleaner_min_cleanable_ratio] = nil
default[:kafka][:log][:cleaner_delete_retention_ms] = nil

# Replication configuration
default[:kafka][:controller][:socket_timeout_ms] = nil
default[:kafka][:controller][:message_queue_size] = nil
default[:kafka][:default_replication_factor] = nil
default[:kafka][:replica][:lag_time_max_ms] = nil
default[:kafka][:replica][:lag_max_messages] = nil
default[:kafka][:replica][:socket_timeout_ms] = nil
default[:kafka][:replica][:socket_receive_buffer_bytes] = nil
default[:kafka][:replica][:fetch_max_bytes] = nil
default[:kafka][:replica][:fetch_wait_max_ms] = nil
default[:kafka][:replica][:fetch_min_bytes] = nil
default[:kafka][:num_replica_fetchers] = nil
default[:kafka][:replica][:high_watermark_checkpoint_interval_ms] = nil
default[:kafka][:fetch][:purgatory_purge_interval_requests] = nil
default[:kafka][:producer][:purgatory_purge_interval_requests] = nil

# Controlled shutdown configuration
default[:kafka][:controlled_shutdown][:max_retries] = nil
default[:kafka][:controlled_shutdown][:retry_backoff_ms] = nil
default[:kafka][:controlled_shutdown][:enabled] = nil

# Leader related configuration (> v0.8.0 configuration options)
default[:kafka][:auto_leader_rebalance_enable] = nil
default[:kafka][:leader][:imbalance_per_broker_percentage] = nil
default[:kafka][:leader][:imbalance_check_interval_seconds] = nil

# Consumer offset management configuration (> v0.8.0 configuration options)
default[:offset_metadata_max_bytes] = nil

# ZooKeeper configuration
default[:kafka][:zookeeper][:connect] = []
default[:kafka][:zookeeper][:connection_timeout_ms] = nil
default[:kafka][:zookeeper][:session_timeout_ms] = nil
default[:kafka][:zookeeper][:sync_time_ms] = nil
default[:kafka][:zookeeper][:path] = nil
