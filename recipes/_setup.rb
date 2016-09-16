#
# Cookbook Name:: kafka
# Recipe:: _setup
#

group node['kafka']['group'] do
  gid node['kafka']['gid'] if node['kafka']['gid']
  only_if { node['kafka']['manage_user'] }
end

user node['kafka']['user'] do
  uid node['kafka']['uid'] if node['kafka']['uid']
  group node['kafka']['group']
  home '/var/empty/kafka'
  shell '/sbin/nologin'
  only_if { node['kafka']['manage_user'] }
end

[
  node['kafka']['version_install_dir'],
  node['kafka']['log_dir'],
  node['kafka']['build_dir'],
].each do |dir|
  directory dir do
    owner node['kafka']['user']
    group node['kafka']['group']
    mode '755'
    recursive true
  end
end

kafka_log_dirs.each do |dir|
  directory dir do
    owner node['kafka']['user']
    group node['kafka']['group']
    mode '755'
    recursive true
  end
end
