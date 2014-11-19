#
# Cookbook Name:: kafka
# Recipe:: _configure
#

directory node.kafka.config_dir do
  owner node.kafka.user
  group node.kafka.group
  mode '755'
  recursive true
end

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
    notifies :create, 'ruby_block[coordinate-kafka-start]', :immediately
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
    notifies :create, 'ruby_block[coordinate-kafka-start]', :immediately
  end
end

template kafka_init_opts[:env_path] do
  source kafka_init_opts.fetch(:env_template, 'env.erb')
  owner 'root'
  group 'root'
  mode '644'
  variables({
    main_class: 'kafka.Kafka',
  })
  if restart_on_configuration_change?
    notifies :create, 'ruby_block[coordinate-kafka-start]', :immediately
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
    user: node.kafka.user,
    env_path: kafka_init_opts[:env_path],
  })
  helper :controlled_shutdown_enabled? do
    !!broker_attribute?(:controlled, :shutdown, :enable)
  end
  if restart_on_configuration_change?
    notifies :create, 'ruby_block[coordinate-kafka-start]', :immediately
  end
end

include_recipe node.kafka.start_coordination.recipe
