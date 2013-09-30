#
# Cookbook Name:: kafka
# Attributes:: zookeeper
#

default[:zookeeper][:data_dir] = '/tmp/zookeeper'
default[:zookeeper][:log_dir] = '/var/log/zookeeper'
default[:zookeeper][:port] = 2181
default[:zookeeper][:max_client_connections] = 0
default[:zookeeper][:jmx_port] = 9998
