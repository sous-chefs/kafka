#
# Cookbook Name:: kafka
# Recipe:: _coordinate
# Function:: Default recipe to start/restart Kafka service
#            Refer issue #58 for details
#
ruby_block "coordinate-kafka-start" do
  block do
    Chef::Log.debug ("Default recipe to coordinate Kafka start is used")
  end
  action :nothing
  notifies :restart, 'service[kafka]', :delayed
end

service 'kafka' do
  provider kafka_init_opts[:provider]
  supports start: true, stop: true, restart: true, status: true
  action kafka_service_actions
end

