#
# Cookbook Name:: kafka
# Recipe:: _defaults
#

unless broker_attribute?(:broker, :id)
  node.default.kafka.broker.broker_id = node.ipaddress.gsub('.', '').to_i % 2**31
end

unless broker_attribute?(:port)
  node.default.kafka.broker.port = 6667
end

#
# GC log options for Kafka.
node.default_unless.kafka.gc_log_opts = %W[
  -Xloggc:#{node.kafka.log_dir}/kafka-gc.log
  -verbose:gc
  -XX:+PrintGCDetails
  -XX:+PrintGCDateStamps
  -XX:+PrintGCTimeStamps
].join(' ')
