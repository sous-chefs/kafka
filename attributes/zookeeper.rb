#
# Cookbook Name:: kafka
# Attributes:: zookeeper
#

#
# Data directory for ZooKeeper state.
default[:zookeeper][:data_dir] = '/tmp/zookeeper'

#
# Log directory for ZooKeeper.
default[:zookeeper][:log_dir] = '/var/log/zookeeper'

#
# Client port for ZooKeeper.
default[:zookeeper][:port] = 2181

#
# Maximum number of connections each client can make to ZooKeeper.
default[:zookeeper][:max_client_connections] = 0

#
# JMX port for ZooKeeper.
default[:zookeeper][:jmx_port] = 9998
