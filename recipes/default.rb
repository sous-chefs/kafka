#
# Cookbook Name:: kafka
# Recipe:: default
#

case node[:kafka][:install_method].to_sym
when :source, :binary
  include_recipe 'kafka::_setup'
  include_recipe %(kafka::#{node[:kafka][:install_method]})
  include_recipe 'kafka::_configure'
else
  Chef::Application.fatal! %(Unknown install_method: #{node[:kafka][:install_method]})
end
