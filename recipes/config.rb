#
# Cookbook Name:: kafka
# Recipe:: config
#
# Copyright 2013, Burt
#
# All rights reserved - Do Not Redistribute
#

config_dir = "#{node[:kafka][:install_dir]}/config"

template "#{config_dir}/log4j.properties" do
  source  "log4j.properties.erb"
  owner user
  group group
  mode  00644
  variables({
    :process => 'kafka',
    :log_dir => node[:kafka][:log_dir]
  })
end

template "#{config_dir}/server.properties" do
  source  "server.properties.erb"
  owner user
  group group
  mode  00644
end
