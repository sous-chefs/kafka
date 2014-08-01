#
# Cookbook Name:: kafka
# Recipe:: _setup
#

group node.kafka.group

user node.kafka.user do
  gid node.kafka.group
  shell '/sbin/nologin'
  supports(manage_home: false)
end

[
  node.kafka.install_dir,
  node.kafka.config_dir,
  node.kafka.log_dir,
  node.kafka.build_dir,
].each do |dir|
  directory dir do
    owner node.kafka.user
    group node.kafka.group
    mode '755'
    recursive true
  end
end

node.kafka.broker.log_dirs.each do |dir|
  directory dir do
    owner node.kafka.user
    group node.kafka.group
    mode '755'
    recursive true
  end
end
