#
# Cookbook Name:: kafka
# Recipe:: zookeeper
#

include_recipe 'kafka'

template ::File.join(node[:kafka][:config_dir], 'zookeeper.properties') do
  source 'zookeeper.properties.erb'
  owner  node[:kafka][:user]
  group  node[:kafka][:group]
  mode   '644'
end

directory node[:zookeeper][:log_dir] do
  owner   node[:kafka][:user]
  group   node[:kafka][:group]
  mode    '755'
  recursive true
end

template ::File.join(node[:kafka][:config_dir], 'zookeeper.log4j.properties') do
  source  'log4j.properties.erb'
  owner node[:kafka][:user]
  group node[:kafka][:group]
  mode  '644'
  variables({
    process: 'zookeeper',
    log_dir: node[:zookeeper][:log_dir]
  })
end

case node[:kafka][:init_style].to_sym
when :sysv
  env_path = value_for_platform({
    'debian' => {'default' => '/etc/default/zookeeper'},
    'default' => '/etc/sysconfig/zookeeper'
  })
  init_script_path = '/etc/init.d/zookeeper'
  source_script_path = 'initd.sh.erb'
  service_provider = nil
  init_script_permissions = '755'
when :upstart
  env_path = '/etc/default/zookeeper'
  init_script_path = '/etc/init/zookeeper.conf'
  source_script_path = 'kafka.upstart.erb'
  service_provider = Chef::Provider::Service::Upstart
  init_script_permissions = '644'
end

template env_path do
  source 'kafka.env.erb'
  owner  'root'
  group  'root'
  mode   '644'
  variables({
    main_class:   'org.apache.zookeeper.server.quorum.QuorumPeerMain',
    jmx_port:     node[:zookeeper][:jmx_port],
    config:        'zookeeper.properties',
    log4j_config:  'zookeeper.log4j.properties'
  })
end

template init_script_path do
  source source_script_path
  owner  'root'
  group  'root'
  mode   init_script_permissions
  variables({daemon_name: 'zookeeper', port: 2181})
end

service 'zookeeper' do
  provider service_provider
  supports start: true, stop: true, restart: true
  action [:enable, :start]
end
