#
# Cookbook Name:: kafka
# Recipe:: default
#

include_recipe 'kafka::_defaults'
include_recipe 'kafka::_setup'
include_recipe 'kafka::_install'
include_recipe 'kafka::_configure'
if kafka_init_style
  include_recipe 'kafka::_service' unless kafka_runit?
  include_recipe node['kafka']['start_coordination']['recipe']
end
