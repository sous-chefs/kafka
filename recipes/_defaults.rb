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

unless broker_attribute?(:host, :name)
  node.default.kafka.broker.host_name = node.hostname
end
