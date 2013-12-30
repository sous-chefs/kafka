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
default[:kafka][:config_dir] = File.join(node[:kafka][:install_dir], 'config')
default[:kafka][:data_dir] = '/var/kafka'
default[:kafka][:log_dir] = '/var/log/kafka'
default[:kafka][:log4j_config] = 'log4j.properties'
default[:kafka][:config] = 'server.properties'

default[:kafka][:user] = 'kafka'
default[:kafka][:group] = 'kafka'

default[:kafka][:log_level] = 'INFO'
default[:kafka][:jmx_port] = 9999

default[:kafka][:heap_opts] = '-Xmx1G -Xms1G'
default[:kafka][:generic_opts] = nil

default[:kafka][:broker_id] = node[:ipaddress].gsub('.', '')
default[:kafka][:host_name] = node[:hostname]
default[:kafka][:port] = 9092
default[:kafka][:network_threads] = 2
default[:kafka][:io_threads] = 2
default[:kafka][:num_partitions] = 1

default[:kafka][:socket][:send_buffer_bytes] = 1048576
default[:kafka][:socket][:receive_buffer_bytes] = 1048576
default[:kafka][:socket][:request_max_bytes] = 104857600

default[:kafka][:log][:dirs] = '/tmp/kafka-logs'
default[:kafka][:log][:flush_interval_messages] = 10000
default[:kafka][:log][:flush_interval_ms] = 1000
default[:kafka][:log][:retention_hours] = 168
default[:kafka][:log][:retention_bytes] = 1073741824
default[:kafka][:log][:segment_bytes] = 536870912
default[:kafka][:log][:cleanup_interval_mins] = 1

default[:kafka][:zookeeper][:connect] = []
default[:kafka][:zookeeper][:timeout] = 1000000

default[:kafka][:metrics][:polling_interval] = 5
default[:kafka][:metrics][:reporters] = ['kafka.metrics.KafkaCSVMetricsReporter']

default[:kafka][:csv_metrics][:dir] = '/tmp/kafka_metrics'
default[:kafka][:csv_metrics][:reporter_enabled] = false
