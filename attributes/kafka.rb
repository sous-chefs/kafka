#
# Cookbook Name:: kafka
# Attributes:: kafka
#
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
