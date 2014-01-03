#
# Cookbook Name:: kafka
# Recipe:: _setup
#

kafka_user   = node[:kafka][:user]
kafka_group  = node[:kafka][:group]

group kafka_group

user kafka_user  do
  gid   kafka_group
  shell '/sbin/nologin'
  supports(manage_home: false)
end

[
  node[:kafka][:install_dir],
  node[:kafka][:config_dir],
  node[:kafka][:log_dir]
].each do |dir|
  directory dir do
    owner     kafka_user
    group     kafka_group
    mode      '755'
    recursive true
    not_if { File.directory?(dir) }
  end
end
