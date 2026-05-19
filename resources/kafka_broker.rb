# frozen_string_literal: true

provides :kafka_broker
unified_mode true

use '_partial/_common'
use '_partial/_config'
use '_partial/_service'

property :cluster_id, [String, nil]
property :format_storage, [true, false], default: false

default_action :create

action_class do
  include Kafka::Helpers

  def start_service_action(resource)
    resource.automatic_start || resource.automatic_restart ? :start : :create
  end
end

action :create do
  if new_resource.format_storage && new_resource.cluster_id.to_s.empty?
    raise Chef::Exceptions::ValidationFailed, 'cluster_id is required when format_storage is true'
  end

  group new_resource.group do
    gid new_resource.gid if new_resource.gid
    only_if { new_resource.manage_user }
  end

  user new_resource.user do
    uid new_resource.uid if new_resource.uid
    group new_resource.group
    home "/var/empty/#{new_resource.user}"
    shell '/sbin/nologin'
    system true
    only_if { new_resource.manage_user }
  end

  directory new_resource.log_dir do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
  end

  kafka_log_dirs.each do |dir|
    directory dir do
      owner new_resource.user
      group new_resource.group
      mode '0755'
      recursive true
    end
  end

  kafka_install new_resource.instance_name do
    user new_resource.user
    group new_resource.group
    version new_resource.version
    scala_version new_resource.scala_version
    base_url new_resource.base_url
    checksum new_resource.checksum
    md5_checksum new_resource.md5_checksum
    sha512_checksum new_resource.sha512_checksum
    install_dir new_resource.install_dir
    version_install_dir new_resource.version_install_dir
    build_dir new_resource.build_dir
    action :install
  end

  kafka_config new_resource.instance_name do
    user new_resource.user
    group new_resource.group
    version new_resource.version
    scala_version new_resource.scala_version
    install_dir new_resource.install_dir
    config_dir new_resource.config_dir
    log_dir new_resource.log_dir
    broker_config new_resource.broker_config
    log4j_config new_resource.log4j_config if new_resource.log4j_config
    env_path new_resource.env_path
    jmx_port new_resource.jmx_port
    jmx_opts new_resource.jmx_opts
    heap_opts new_resource.heap_opts
    generic_opts new_resource.generic_opts
    gc_log_opts new_resource.gc_log_opts
    log4j_opts new_resource.log4j_opts
    jvm_performance_opts new_resource.jvm_performance_opts
    service_name new_resource.service_name
    automatic_restart new_resource.automatic_restart
    action :create
  end

  execute "format kafka storage for #{new_resource.instance_name}" do
    command "#{::File.join(new_resource.install_dir, 'bin', 'kafka-storage.sh')} format --ignore-formatted -t #{new_resource.cluster_id} -c #{::File.join(new_resource.config_dir, 'server.properties')}"
    user new_resource.user
    group new_resource.group
    only_if { new_resource.format_storage }
  end

  kafka_service new_resource.instance_name do
    user new_resource.user
    group new_resource.group
    install_dir new_resource.install_dir
    config_dir new_resource.config_dir
    env_path new_resource.env_path
    service_name new_resource.service_name
    automatic_start new_resource.automatic_start
    automatic_restart new_resource.automatic_restart
    ulimit_file new_resource.ulimit_file
    kill_timeout new_resource.kill_timeout
    action start_service_action(new_resource)
  end
end

action :delete do
  kafka_service new_resource.instance_name do
    service_name new_resource.service_name
    action :delete
  end

  kafka_config new_resource.instance_name do
    config_dir new_resource.config_dir
    env_path new_resource.env_path
    action :delete
  end

  kafka_install new_resource.instance_name do
    version new_resource.version
    scala_version new_resource.scala_version
    install_dir new_resource.install_dir
    version_install_dir new_resource.version_install_dir
    build_dir new_resource.build_dir
    action :delete
  end

  kafka_log_dirs.each do |dir|
    directory dir do
      recursive true
      action :delete
    end
  end

  directory new_resource.log_dir do
    recursive true
    action :delete
  end
end
