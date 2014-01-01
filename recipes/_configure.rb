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

sysconfig_path = case node[:platform]
  when 'debian'
    '/etc/default/kafka'
  else
    '/etc/sysconfig/kafka'
end

template sysconfig_path do
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

template '/etc/init.d/kafka' do
  source 'initd.sh.erb'
  owner  'root'
  group  'root'
  mode   '755'
  variables({daemon_name: 'kafka'})
end

service 'kafka' do
  supports start: true, stop: true, restart: true
  action [:enable]
end
