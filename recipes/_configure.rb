#
# Cookbook:: kafka
# Recipe:: _configure
#

directory node['kafka']['config_dir'] do
  owner node['kafka']['user']
  group node['kafka']['group']
  mode '755'
  recursive true
end

template ::File.join(node['kafka']['config_dir'], 'log4j.properties') do
  source 'log4j.properties.erb'
  owner node['kafka']['user']
  group node['kafka']['group']
  mode '644'
  helpers(Kafka::Log4J)
  variables(config: node['kafka']['log4j'])
  if restart_on_configuration_change?
    notifies :run, 'ruby_block[coordinate-kafka-start]', :delayed
  end
end

template ::File.join(node['kafka']['config_dir'], 'server.properties') do
  source 'server.properties.erb'
  owner node['kafka']['user']
  group node['kafka']['group']
  mode '600'
  sensitive node['kafka']['senstive_config']
  helpers(Kafka::Configuration)
  variables(config: node['kafka']['broker'].sort_by(&:first))
  if restart_on_configuration_change?
    notifies :run, 'ruby_block[coordinate-kafka-start]', :delayed
  end
end
