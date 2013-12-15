#
# Cookbook Name:: kafka
# Recipe:: default
#

case node[:kafka][:install_method]
when :source, :binary
  include_recipe "kafka::#{node[:kafka][:install_method]}"
else
  Chef::Application.fatal!("Unknown install_method: #{node[:kafka][:install_method]}")
end
