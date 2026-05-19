# frozen_string_literal: true

provides :kafka_service
unified_mode true

use '_partial/_common'
use '_partial/_config'
use '_partial/_service'

action_class do
  include Kafka::Helpers
end

action :create do
  systemd_unit "#{new_resource.service_name}.service" do
    content kafka_systemd_content
    action [:create, :enable]
  end
end

action :start do
  systemd_unit "#{new_resource.service_name}.service" do
    content kafka_systemd_content
    action [:create, :enable, :start]
  end
end

action :restart do
  systemd_unit "#{new_resource.service_name}.service" do
    content kafka_systemd_content
    action :restart
  end
end

action :stop do
  systemd_unit "#{new_resource.service_name}.service" do
    action :stop
  end
end

action :delete do
  systemd_unit "#{new_resource.service_name}.service" do
    action [:stop, :disable, :delete]
  end
end
