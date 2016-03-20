#
# Cookbook Name:: kafka
# Recipe:: default
#

if node.kafka.version == '0.8.0'
  Chef::Log.warn('Support for Kafka v0.8.0 is deprecated and will be removed in the next major version')
end

include_recipe 'kafka::_defaults'
include_recipe 'kafka::_setup'
include_recipe 'kafka::_install'
include_recipe 'kafka::_configure'
