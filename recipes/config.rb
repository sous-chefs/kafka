#
# Cookbook Name:: kafka
# Recipe:: config
#

config_dir = "#{node[:kafka][:install_dir]}/config"

template "#{config_dir}/#{node[:kafka][:log4j_config]}" do
  source  "log4j.properties.erb"
  owner user
  group group
  mode  00644
  variables({
    :process => 'kafka',
    :log_dir => node[:kafka][:log_dir]
  })
end

template "#{config_dir}/#{node[:kafka][:config]}" do
  source  "server.properties.erb"
  owner user
  group group
  mode  00644
end
