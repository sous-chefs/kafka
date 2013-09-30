#
# Cookbook Name:: kafka
# Recipe:: standalone
#

config_dir = "#{node[:kafka][:install_dir]}/config"

template "#{config_dir}/zookeeper.properties" do
  source "zookeeper.properties.erb"
  owner user
  group group
  mode  00644
end

directory node[:zookeeper][:log_dir] do
  owner   user
  group   group
  mode    00755
  recursive true
  action :create
  not_if { File.directory?(node[:zookeeper][:log_dir]) }
end

template "#{config_dir}/zookeeper.log4j.properties" do
  source  "log4j.properties.erb"
  owner user
  group group
  mode  00644
  variables({
    :process => 'zookeeper',
    :log_dir => node[:zookeeper][:log_dir]
  })
end

template '/etc/init.d/zookeeper' do
  source 'initd.script.erb'
  owner 'root'
  group 'root'
  mode 00755
  variables({
    :daemon_name => 'zookeeper',
    :main_class => 'org.apache.zookeeper.server.quorum.QuorumPeerMain',
    :jmx_port => node[:zookeeper][:jmx_port],
    :log4j_config => 'zookeeper.log4j.properties'
  })
end

service 'zookeeper' do
  supports :start => true, :stop => true, :restart => true
  action [:enable]
end
