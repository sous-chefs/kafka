#
# Cookbook Name:: kafka
# Recipe:: _coordinate
#

ruby_block 'coordinate-kafka-start' do
  block do
    Chef::Log.debug 'Default recipe to coordinate Kafka start is used'
  end
  action :nothing
  notifies :restart, kafka_service_resource, :delayed
end
