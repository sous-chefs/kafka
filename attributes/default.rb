#
# Cookbook Name:: kafka
# Attributes:: default
#

default[:kafka][:version] = '0.8.0-beta1'
default[:kafka][:base_url] = 'https://dist.apache.org/repos/dist/release/kafka'
default[:kafka][:checksum] = ''
default[:kafka][:scala_version] = '2.9.2'

default[:kafka][:install_dir] = '/opt/kafka'
default[:kafka][:data_dir] = '/var/kafka'
default[:kafka][:log_dir] = '/var/log/kafka'

default[:kafka][:zk] ||= {}
default[:kafka][:zk][:chroot] = 'brokers'
default[:kafka][:zk][:connection_timeout] = 10000
default[:kafka][:zk][:nodes] = []

default[:kafka][:num_partitions] = 1
default[:kafka][:broker_id] = nil
default[:kafka][:broker_host_name] = nil
default[:kafka][:port] = 9092
default[:kafka][:threads] = nil
default[:kafka][:log_flush_interval] = 10000
default[:kafka][:log_flush_time_interval] = 1000
default[:kafka][:log_flush_scheduler_time_interval] = 1000
default[:kafka][:log_retention_hours] = 168
default[:kafka][:log_retention_size] = 1073741824
default[:kafka][:log_file_size] = 536870912
default[:kafka][:log_cleanup_interval_mins] = 1

default[:kafka][:user] = 'kafka'
default[:kafka][:group] = 'kafka'

default[:kafka][:log_level] = "INFO"
default[:kafka][:jmx_port] = 9999

default[:kafka][:send_buffer] = 1048576
default[:kafka][:receive_buffer] = 1048576
default[:kafka][:max_socket_request_bytes] = 104857600
