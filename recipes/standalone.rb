#
# Cookbook Name:: kafka
# Recipe:: standalone
#

include_recipe 'kafka::binary'

config_dir = "#{node[:kafka][:install_dir]}/config"

template "#{config_dir}/zookeeper.properties" do
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

template "#{config_dir}/zookeeper.log4j.properties" do
  source  "log4j.properties.erb"
  owner   node[:kafka][:user]
  group   node[:kafka][:group]
  mode    '644'
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
    daemon_name:  'zookeeper',
    main_class:   'org.apache.zookeeper.server.quorum.QuorumPeerMain',
    jmx_port:     node[:zookeeper][:jmx_port],
    log4j_config: 'zookeeper.log4j.properties'
  )
end

service 'zookeeper' do
  supports start: true, stop: true, restart: true
  action [:enable, :start]
end

# Work around: https://tickets.opscode.com/browse/CHEF-3694
kafka_service = resources(service: 'kafka')
kafka_service.action << :start
