#
# Cookbook Name:: kafka
# Attributes:: default
#

default[:kafka][:version] = '0.8.0-beta1'
default[:kafka][:base_url] = 'https://dist.apache.org/repos/dist/release/kafka'
default[:kafka][:checksum] = ''
default[:kafka][:scala_version] = '2.9.2'

default[:kafka][:install_dir] = '/opt/kafka'
default[:kafka][:data_dir] = '/var/kafka'
default[:kafka][:log_dir] = '/var/log/kafka'

default[:kafka][:user] = 'kafka'
default[:kafka][:group] = 'kafka'

default[:kafka][:log_level] = "INFO"
default[:kafka][:jmx_port] = 9999
