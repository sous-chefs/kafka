#
# Cookbook Name:: kafka
# Recipe:: zookeeper
#

include_recipe 'kafka'

template ::File.join(node[:kafka][:config_dir], 'zookeeper.properties') do
  source 'zookeeper.properties.erb'
  owner node[:kafka][:user]
  group node[:kafka][:group]
  mode '644'
end

directory node[:zookeeper][:log_dir] do
  owner node[:kafka][:user]
  group node[:kafka][:group]
  mode '755'
  recursive true
end

template ::File.join(node[:kafka][:config_dir], 'zookeeper.log4j.properties') do
  source 'log4j.properties.erb'
  owner node[:kafka][:user]
  group node[:kafka][:group]
  mode '644'
  variables({
    process: 'zookeeper',
    log_dir: node[:zookeeper][:log_dir]
  })
end

template zookeeper_init_opts[:env_path] do
  source 'kafka.env.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables({
    main_class: 'org.apache.zookeeper.server.quorum.QuorumPeerMain',
    jmx_port: node[:zookeeper][:jmx_port],
    config: 'zookeeper.properties',
    log4j_config: 'zookeeper.log4j.properties'
  })
end

template zookeeper_init_opts[:script_path] do
  source zookeeper_init_opts[:source]
  owner 'root'
  group 'root'
  mode zookeeper_init_opts[:permissions]
  variables({
    daemon_name: 'zookeeper',
    port: 2181,
    user: node[:kafka][:user]
  })
end

service 'zookeeper' do
  provider zookeeper_init_opts[:provider]
  supports start: true, stop: true, restart: true
  action [:enable, :start]
end
