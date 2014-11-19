#
# Cookbook Name:: kafka
# Recipe:: _setup
#

group node.kafka.group

user node.kafka.user do
  gid node.kafka.group
  home '/var/empty/kafka'
  shell '/sbin/nologin'
end

[
  node.kafka.version_install_dir,
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

kafka_log_dirs.each do |dir|
  directory dir do
    owner node.kafka.user
    group node.kafka.group
    mode '755'
    recursive true
  end
end
