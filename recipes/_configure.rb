#
# Cookbook Name:: kafka
# Recipe:: _configure
#

template File.join(node[:kafka][:config_dir], node[:kafka][:log4j_config]) do
  source 'log4j.properties.erb'
  owner  node[:kafka][:user]
  group  node[:kafka][:group]
  mode   '644'
  variables({
    process: 'kafka',
    log_dir: node[:kafka][:log_dir]
  })
end

template File.join(node[:kafka][:config_dir], node[:kafka][:config]) do
  source 'server.properties.erb'
  owner  node[:kafka][:user]
  group  node[:kafka][:group]
  mode   '644'
end

case node[:kafka][:init_style]
when :sysv
  env_path = value_for_platform({
    'debian' => {'default' => '/etc/default/kafka'},
    'default' => '/etc/sysconfig/kafka'
  })
  init_script_path = '/etc/init.d/kafka'
  source_script_path = 'initd.sh.erb'
  service_provider = nil
when :upstart
  env_path = '/etc/default/kafka'
  init_script_path = '/etc/init/kafka.conf'
  source_script_path = 'kafka.upstart.erb'
  service_provider = Chef::Provider::Service::Upstart
end

template env_path do
  source 'kafka.env.erb'
  owner  'root'
  group  'root'
  mode   '644'
  variables({
    main_class:   'kafkaServer kafka.Kafka',
    jmx_port:     node[:kafka][:jmx_port],
    config:       node[:kafka][:config],
    log4j_config: 'log4j.properties'
  })
end

template init_script_path do
  source source_script_path
  owner  'root'
  group  'root'
  mode   '755'
  variables({daemon_name: 'kafka'})
end

service 'kafka' do
  provider service_provider
  supports start: true, stop: true, restart: true
  action [:enable]
end
