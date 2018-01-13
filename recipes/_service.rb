#
# Cookbook Name:: kafka
# Recipe:: _service
#

file kafka_init_opts[:env_path] do
  owner 'root'
  group 'root'
  mode '644'
  content kafka_env.to_file_content(!kafka_systemd?)
  if restart_on_configuration_change?
    notifies :create, 'ruby_block[coordinate-kafka-start]', :delayed
  end
end unless kafka_runit?

template kafka_init_opts[:script_path] do
  source kafka_init_opts[:source]
  owner 'root'
  group 'root'
  mode kafka_init_opts[:permissions]
  variables(
    daemon_name: 'kafka',
    port: node['kafka']['broker']['port'],
    user: node['kafka']['user'],
    env_path: kafka_init_opts[:env_path],
    ulimit: node['kafka']['ulimit_file'],
    kill_timeout: node['kafka']['kill_timeout'],
  )
  helper :controlled_shutdown_enabled? do
    !!fetch_broker_attribute(:controlled, :shutdown, :enable)
  end
  if kafka_systemd?
    notifies :run, 'execute[kafka systemctl daemon-reload]', :immediately
  end
  if restart_on_configuration_change?
    notifies :create, 'ruby_block[coordinate-kafka-start]', :delayed
  end
end unless kafka_runit?

execute 'kafka systemctl daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end if kafka_systemd?

runit_service 'kafka' do
  log false
  env kafka_env.to_h.merge(
    'KAFKA_USER' => node['kafka']['user'],
    'KAFKA_LIMITS' => node['kafka']['ulimit_file'].to_s,
  )
  sv_bin format('sleep 5 && %s', node['runit']['sv_bin'])
  restart_on_update false
  start_down true unless start_automatically?
  sv_timeout node['kafka']['kill_timeout'] if node['kafka']['kill_timeout']
  control %w[t] if fetch_broker_attribute(:controlled, :shutdown, :enable)
  action kafka_service_actions
end if kafka_runit?

service 'kafka' do
  provider kafka_init_opts[:provider]
  supports start: true, stop: true, restart: true, status: true
  action kafka_service_actions
end unless kafka_runit?

include_recipe node['kafka']['start_coordination']['recipe']
