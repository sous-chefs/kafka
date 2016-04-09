#
# Cookbook Name:: kafka
# Recipe:: _setup
#

group node.kafka.group do
  only_if { node.kafka.manage_user }
end

user node.kafka.user do
  gid node.kafka.group
  home '/var/empty/kafka'
  shell '/sbin/nologin'
  only_if { node.kafka.manage_user }
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

directory node.kafka.scripts_dir do
  mode '755'
  recursive true
end

%w[post-start stop].each do |script|
  cookbook_file ::File.join(node.kafka.scripts_dir, script) do
    source sprintf('%s.bash', script)
    mode '755'
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
