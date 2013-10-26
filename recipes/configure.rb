#
# Cookbook Name:: kafka
# Recipe:: configure
#

config_dir = "#{node[:kafka][:install_dir]}/config"

template "#{config_dir}/#{node[:kafka][:log4j_config]}" do
  source  "log4j.properties.erb"
  owner node[:kafka][:user]
  group node[:kafka][:group]
  mode  '644'
  variables({
    :process => 'kafka',
    :log_dir => node[:kafka][:log_dir]
  })
end

template "#{config_dir}/#{node[:kafka][:config]}" do
  source  "server.properties.erb"
  owner node[:kafka][:user]
  group node[:kafka][:group]
  mode  '644'
end
