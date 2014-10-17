#
# Cookbook Name:: kafka
# Recipe:: default
#

case kafka_install_method
when :source, :binary
  include_recipe 'kafka::_setup'
  include_recipe 'kafka::%s' % node.kafka.install_method
  include_recipe 'kafka::_configure'
else
  Chef::Application.fatal!('Unknown install_method: %s' % node.kafka.install_method.inspect)
end
