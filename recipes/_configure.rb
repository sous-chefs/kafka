#
# Cookbook Name:: kafka
# Recipe:: _configure
#

template ::File.join(node[:kafka][:config_dir], node[:kafka][:log4j_config]) do
  source 'log4j.properties.erb'
  owner node[:kafka][:user]
  group node[:kafka][:group]
  mode '644'
  variables({
    process: 'kafka',
    log_dir: node[:kafka][:log_dir]
  })
end

template ::File.join(node[:kafka][:config_dir], node[:kafka][:config]) do
  source 'server.properties.erb'
  owner node[:kafka][:user]
  group node[:kafka][:group]
  mode '644'
  variables({
    zookeeper_connect: zookeeper_connect_string
  })
  helper(:config) { node[:kafka] }
  helper(:kafka_v0_8_0?) { node[:kafka][:version] == '0.8.0' }
end

template kafka_init_opts[:env_path] do
  source 'kafka.env.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables({
    main_class: 'kafka.Kafka',
    jmx_port: node[:kafka][:jmx_port],
    config: node[:kafka][:config],
    log4j_config: 'log4j.properties'
  })
end

template kafka_init_opts[:script_path] do
  source kafka_init_opts[:source]
  owner 'root'
  group 'root'
  mode kafka_init_opts[:permissions]
  variables({
    daemon_name: 'kafka',
    port: node[:kafka][:port],
    user: node[:kafka][:user]
  })
end

service 'kafka' do
  provider kafka_init_opts[:provider]
  supports start: true, stop: true, restart: true
  action [:enable]
end
