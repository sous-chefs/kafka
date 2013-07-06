#
# Cookbook Name:: kafka
# Recipe:: config
#
# Copyright 2013, Burt
#
# All rights reserved - Do Not Redistribute
#

%w[server.properties log4j.properties].each do |template_file|
  template "#{node[:kafka][:install_dir]}/config/#{template_file}" do
    source  "#{template_file}.erb"
    owner user
    group group
    mode  00755
  end
end
