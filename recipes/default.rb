#
# Cookbook Name:: kafka
# Recipe:: default
#

include_recipe 'java'

kafka_user   = node[:kafka][:user]
kafka_group  = node[:kafka][:group]
install_dir  = node[:kafka][:install_dir]
broker_id    = node[:kafka][:broker_id]
host_name    = node[:kafka][:host_name]

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

template '/etc/init.d/kafka' do
  source 'initd.script.erb'
  owner 'root'
  group 'root'
  mode '755'
  variables({
    :daemon_name => 'kafka',
    :main_class => 'kafka.Kafka',
    :jmx_port => node[:kafka][:jmx_port],
    :log4j_config => node[:kafka][:log4j_config],
    :config => node[:kafka][:config]
  })
end

include_recipe 'kafka::configure'

service 'kafka' do
  supports :start => true, :stop => true, :restart => true
  action [:enable]
end
