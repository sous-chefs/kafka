#
# Cookbook Name:: kafka
# Attributes:: kafka
#

default[:kafka][:broker_id] = nil
default[:kafka][:host_name] = nil
default[:kafka][:port] = 9092
default[:kafka][:network_threads] = 2
default[:kafka][:io_threads] = 2
default[:kafka][:num_partitions] = 1

# socket
default[:kafka][:socket][:send_buffer_bytes] = 1048576
default[:kafka][:socket][:receive_buffer_bytes] = 1048576
default[:kafka][:socket][:request_max_bytes] = 104857600

# log
default[:kafka][:log][:dirs] = '/tmp/kafka-logs'
default[:kafka][:log][:flush_interval_messages] = 10000
default[:kafka][:log][:flush_interval_ms] = 1000
default[:kafka][:log][:retention_hours] = 168
default[:kafka][:log][:retention_bytes] = 1073741824
default[:kafka][:log][:segment_bytes] = 536870912
default[:kafka][:log][:cleanup_interval_mins] = 1

# zookeeper
default[:kafka][:zookeeper][:connect] = []
default[:kafka][:zookeeper][:timeout] = 1000000

# metrics
default[:kafka][:metrics][:polling_interval] = 5
default[:kafka][:metrics][:reporters] = ['kafka.metrics.KafkaCSVMetricsReporter']

# csv_metrics
default[:kafka][:csv_metrics][:dir] = '/tmp/kafka_metrics'
default[:kafka][:csv_metrics][:reporter_enabled] = false
