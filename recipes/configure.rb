#
# Cookbook Name:: kafka
# Recipe:: configure
#

kafka_user   = node[:kafka][:user]
kafka_group  = node[:kafka][:group]
broker_id    = node[:kafka][:broker_id]
host_name    = node[:kafka][:host_name]
install_dir  = node[:kafka][:install_dir]
config_dir   = "#{node[:kafka][:install_dir]}/config"

group kafka_group

user kafka_user  do
  gid   kafka_group
  home  "/home/#{kafka_user}"
  shell '/bin/false'
  supports(manage_home: false)
end

[
  install_dir,
  "#{install_dir}/bin",
  "#{install_dir}/config",
  "#{install_dir}/libs",
  node[:kafka][:log_dir],
  node[:kafka][:data_dir]
].each do |dir|
  directory dir do
    owner     kafka_user
    group     kafka_group
    mode      '755'
    recursive true
    not_if { File.directory?(dir) }
  end
end

template "#{config_dir}/#{node[:kafka][:log4j_config]}" do
  source  'log4j.properties.erb'
  owner node[:kafka][:user]
  group node[:kafka][:group]
  mode  '644'
  variables(
    process: 'kafka',
    log_dir: node[:kafka][:log_dir]
  )
end

template "#{config_dir}/#{node[:kafka][:config]}" do
  source  'server.properties.erb'
  owner node[:kafka][:user]
  group node[:kafka][:group]
  mode  '644'
end

template '/etc/init.d/kafka' do
  source 'initd.script.erb'
  owner 'root'
  group 'root'
  mode '755'
  variables(
    daemon_name:  'kafka',
    main_class:   'kafka.Kafka',
    jmx_port:     node[:kafka][:jmx_port],
    log4j_config: node[:kafka][:log4j_config],
    config:       node[:kafka][:config]
  )
end

service 'kafka' do
  supports start: true, stop: true, restart: true
  action [:enable]
end
