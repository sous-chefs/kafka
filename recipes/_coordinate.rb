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

runit_service 'kafka' do
  log false
  env kafka_env.to_h.merge(
    'KAFKA_USER' => node['kafka']['user'],
    'KAFKA_LIMITS' => node['kafka']['ulimit_file'].to_s,
  )
  sv_bin format('sleep 5 && %s', node['runit']['sv_bin'])
  restart_on_update false
  start_down true
  sv_timeout node['kafka']['kill_timeout'] if node['kafka']['kill_timeout']
  control %w[t] if fetch_broker_attribute(:controlled, :shutdown, :enable)
  if restart_on_configuration_change?
    notifies :create, 'ruby_block[coordinate-kafka-start]', :immediately
  end
  action kafka_service_actions
end if kafka_runit?

service 'kafka' do
  provider kafka_init_opts[:provider]
  supports start: true, stop: true, restart: true, status: true
  action kafka_service_actions
end unless kafka_runit?
