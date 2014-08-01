#
# Cookbook Name:: kafka
# Recipe:: _configure
#

template ::File.join(node.kafka.config_dir, 'log4j.properties') do
  source 'log4j.properties.erb'
  owner node.kafka.user
  group node.kafka.group
  mode '644'
  helpers(Kafka::Log4J)
  variables({
    config: node.kafka.log4j,
  })
  if restart_on_configuration_change?
    notifies :restart, 'service[kafka]', :delayed
  end
end

template ::File.join(node.kafka.config_dir, 'server.properties') do
  source 'server.properties.erb'
  owner node.kafka.user
  group node.kafka.group
  mode '644'
  helper :config do
    node.kafka.broker.sort_by(&:first)
  end
  helpers(Kafka::Configuration)
  if restart_on_configuration_change?
    notifies :restart, 'service[kafka]', :delayed
  end
end

template kafka_init_opts[:env_path] do
  source 'env.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables({
    main_class: 'kafka.Kafka',
  })
  if restart_on_configuration_change?
    notifies :restart, 'service[kafka]', :delayed
  end
end

template kafka_init_opts[:script_path] do
  source kafka_init_opts[:source]
  owner 'root'
  group 'root'
  mode kafka_init_opts[:permissions]
  variables({
    daemon_name: 'kafka',
    port: node.kafka.broker.port,
    user: node.kafka.user
  })
  if restart_on_configuration_change?
    notifies :restart, 'service[kafka]', :delayed
  end
end

service 'kafka' do
  provider kafka_init_opts[:provider]
  supports start: true, stop: true, restart: true, status: true
  action kafka_service_actions
end
