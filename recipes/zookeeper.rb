#
# Cookbook Name:: kafka
# Recipe:: zookeeper
#

include_recipe 'kafka::default'

template File.join(node[:kafka][:config_dir], 'zookeeper.properties') do
  source "zookeeper.properties.erb"
  owner  node[:kafka][:user]
  group  node[:kafka][:group]
  mode   '644'
end

directory node[:zookeeper][:log_dir] do
  owner   node[:kafka][:user]
  group   node[:kafka][:group]
  mode    '755'
  recursive true
end

template File.join(node[:kafka][:config_dir], node[:kafka][:log4j_config]) do
  source  'log4j.properties.erb'
  owner node[:kafka][:user]
  group node[:kafka][:group]
  mode  '644'
  variables(
    process: 'zookeeper',
    log_dir: node[:zookeeper][:log_dir]
  )
end

template '/etc/init.d/zookeeper' do
  source 'initd.script.erb'
  owner 'root'
  group 'root'
  mode '755'
  variables(
    daemon_name:   'zookeeper',
    start_command: 'zookeeper-server-start.sh',
    jmx_port:       node[:zookeeper][:jmx_port],
    config:        'zookeeper.properties'
  )
end

service 'zookeeper' do
  supports start: true, stop: true, restart: true
  action [:enable, :start]
end
