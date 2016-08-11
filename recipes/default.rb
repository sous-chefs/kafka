#
# Cookbook Name:: kafka
# Recipe:: default
#

include_recipe 'kafka::_defaults'
include_recipe 'kafka::_setup'
include_recipe 'kafka::_install'
include_recipe 'kafka::_configure'
include_recipe 'kafka::_service' if node['kafka']['init_style']
