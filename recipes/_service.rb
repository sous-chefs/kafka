#
# Cookbook Name:: kafka
# Recipe:: _service
#

template kafka_init_opts[:env_path] do
  source 'env.erb'
  owner 'root'
  group 'root'
  mode '644'
  helpers(Kafka::EnvFile)
  if restart_on_configuration_change?
    notifies :create, 'ruby_block[coordinate-kafka-start]', :immediately
  end
end

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
  if kafka_init_style == :systemd
    notifies :run, 'execute[kafka systemctl daemon-reload]', :immediately
  end
  if restart_on_configuration_change?
    notifies :create, 'ruby_block[coordinate-kafka-start]', :immediately
  end
end

execute 'kafka systemctl daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end if kafka_init_style == :systemd

include_recipe node['kafka']['start_coordination']['recipe']
