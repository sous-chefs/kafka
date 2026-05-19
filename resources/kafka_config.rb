# frozen_string_literal: true

provides :kafka_config
unified_mode true

use '_partial/_common'
use '_partial/_config'
use '_partial/_service'

action_class do
  include Kafka::Helpers
end

action :create do
  directory new_resource.config_dir do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
  end

  directory new_resource.log_dir do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
  end

  file new_resource.env_path do
    owner 'root'
    group 'root'
    mode '0644'
    content kafka_env_content
    notifies :restart, "systemd_unit[#{new_resource.service_name}.service]", :delayed if new_resource.automatic_restart
  end

  template ::File.join(new_resource.config_dir, 'log4j.properties') do
    source 'log4j.properties.erb'
    cookbook 'kafka'
    owner new_resource.user
    group new_resource.group
    mode '0644'
    helpers(Kafka::Log4J)
    variables(config: new_resource.log4j_config || kafka_default_log4j_config)
    notifies :restart, "systemd_unit[#{new_resource.service_name}.service]", :delayed if new_resource.automatic_restart
  end

  template ::File.join(new_resource.config_dir, 'server.properties') do
    source 'server.properties.erb'
    cookbook 'kafka'
    owner new_resource.user
    group new_resource.group
    mode '0600'
    helpers(Kafka::Configuration)
    variables(config: new_resource.broker_config.sort_by { |key, _value| key.to_s })
    notifies :restart, "systemd_unit[#{new_resource.service_name}.service]", :delayed if new_resource.automatic_restart
  end
end

action :delete do
  file new_resource.env_path do
    action :delete
  end

  file ::File.join(new_resource.config_dir, 'log4j.properties') do
    action :delete
  end

  file ::File.join(new_resource.config_dir, 'server.properties') do
    action :delete
  end

  directory new_resource.config_dir do
    recursive true
    action :delete
  end
end
