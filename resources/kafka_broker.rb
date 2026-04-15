# frozen_string_literal: true

provides :kafka_broker
unified_mode true

property :version, String, default: '3.9.1'
property :scala_version, String, default: '2.13'
property :base_url, String, default: 'https://archive.apache.org/dist/kafka'
property :checksum, String, default: 'dd4399816e678946cab76e3bd1686103555e69bc8f2ab8686cda71aa15bc31a3'

property :install_dir, String, default: '/opt/kafka'
property :version_install_dir, String, default: lazy { "#{install_dir}-#{version}" }
property :config_dir, String, default: lazy { ::File.join(install_dir, 'config') }
property :log_dir, String, default: '/var/log/kafka'

property :jmx_port, [Integer, String], default: 9999
property :jmx_opts, String, default: '-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false'
property :heap_opts, String, default: '-Xms1G -Xmx1G'
property :generic_opts, [String, nil]
property :gc_log_opts, String, default: lazy { "-Xlog:gc*:file=#{::File.join(log_dir, 'kafka-gc.log')}:time,tags" }
property :log4j_opts, String, default: lazy { "-Dlog4j.configuration=file:#{::File.join(config_dir, 'log4j.properties')}" }
property :jvm_performance_opts, String, default: '-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -Djava.awt.headless=true'

property :user, String, default: 'kafka'
property :group, [String, Integer], default: 'kafka'
property :manage_user, [true, false], default: true
property :uid, [String, Integer, nil], default: nil
property :gid, [String, Integer, nil], default: nil

property :service_name, String, default: 'kafka'
property :ulimit_file, [Integer, String, nil], default: nil
property :automatic_start, [true, false], default: false
property :automatic_restart, [true, false], default: false
property :kill_timeout, [Integer, String], default: 10
property :manage_java, [true, false], default: true
property :java_version, String, default: '17'

property :cluster_id, [String, nil], desired_state: false
property :broker, Hash, default: {}
property :log4j, Hash, default: {}

default_action :create

action_class do
  include KafkaCookbook::Helpers
end

action :create do
  raise 'cluster_id is required when process.roles is configured for KRaft mode' if kraft_mode?(new_resource) && new_resource.cluster_id.nil?
  raise 'broker[\'log.dirs\'] or broker[\'metadata.log.dir\'] is required for KRaft mode' if kraft_mode?(new_resource) && storage_dir(new_resource).nil?

  group new_resource.group do
    gid new_resource.gid unless new_resource.gid.nil?
    only_if { new_resource.manage_user }
  end

  if new_resource.manage_java
    if platform_family?('amazon', 'rhel')
      raise 'Managed Java on Amazon Linux and supported RHEL-family platforms currently supports java_version 17 only; set manage_java false to supply another JDK externally' unless new_resource.java_version == '17'

      corretto_install new_resource.java_version do
        default true
      end
    else
      temurin_package_install new_resource.java_version do
        default true
      end
    end
  end

  package %w(tar gzip)

  user new_resource.user do
    uid new_resource.uid unless new_resource.uid.nil?
    group new_resource.group
    home '/var/empty/kafka'
    shell '/sbin/nologin'
    only_if { new_resource.manage_user }
  end

  [new_resource.version_install_dir, new_resource.log_dir, *kafka_log_dirs(new_resource)].uniq.each do |managed_directory|
    directory managed_directory do
      owner new_resource.user
      group new_resource.group
      mode '0755'
      recursive true
    end
  end

  remote_file cached_archive_path(new_resource) do
    source remote_path(new_resource)
    checksum new_resource.checksum
    mode '0644'
  end

  execute "extract-kafka-#{new_resource.name}" do
    command "tar zxf #{cached_archive_path(new_resource)} --strip-components=1 -C #{new_resource.version_install_dir}"
    not_if { kafka_installed?(new_resource) }
  end

  execute "chown-kafka-install-#{new_resource.name}" do
    command "chown -R #{new_resource.user}:#{new_resource.group} #{new_resource.version_install_dir}"
    action :nothing
    subscribes :run, "execute[extract-kafka-#{new_resource.name}]", :immediately
  end

  link new_resource.install_dir do
    owner new_resource.user
    group new_resource.group
    to new_resource.version_install_dir
  end

  template ::File.join(new_resource.config_dir, 'log4j.properties') do
    cookbook 'kafka'
    source 'log4j.properties.erb'
    owner new_resource.user
    group new_resource.group
    mode '0644'
    helpers(KafkaCookbook::Log4J)
    variables(config: effective_log4j(new_resource))
    notifies :restart, "systemd_unit[#{new_resource.service_name}.service]", :delayed if restart_on_configuration_change?(new_resource)
  end

  template ::File.join(new_resource.config_dir, 'server.properties') do
    cookbook 'kafka'
    source 'server.properties.erb'
    owner new_resource.user
    group new_resource.group
    mode '0600'
    sensitive true
    helpers(KafkaCookbook::Configuration)
    variables(config: new_resource.broker.sort.to_h)
    notifies :restart, "systemd_unit[#{new_resource.service_name}.service]", :delayed if restart_on_configuration_change?(new_resource)
  end

  file environment_file_path(new_resource) do
    owner 'root'
    group 'root'
    mode '0644'
    content(
      KafkaCookbook::Env.new(
        'scala_version' => new_resource.scala_version,
        'jmx_port' => new_resource.jmx_port,
        'generic_opts' => new_resource.generic_opts,
        'jvm_performance_opts' => new_resource.jvm_performance_opts,
        'gc_log_opts' => new_resource.gc_log_opts,
        'log4j_opts' => new_resource.log4j_opts,
        'heap_opts' => new_resource.heap_opts,
        'jmx_opts' => new_resource.jmx_opts
      ).to_file_content
    )
    notifies :restart, "systemd_unit[#{new_resource.service_name}.service]", :delayed if restart_on_configuration_change?(new_resource)
  end

  execute "format-kafka-storage-#{new_resource.name}" do
    command "#{new_resource.install_dir}/bin/kafka-storage.sh format --ignore-formatted --cluster-id #{new_resource.cluster_id} --config #{::File.join(new_resource.config_dir, 'server.properties')}"
    environment(
      'JMX_PORT' => '',
      'KAFKA_JMX_OPTS' => ''
    )
    user new_resource.user
    group new_resource.group
    not_if { !kraft_mode?(new_resource) || ::File.exist?(::File.join(storage_dir(new_resource), 'meta.properties')) }
  end

  systemd_unit "#{new_resource.service_name}.service" do
    content service_unit_content(new_resource)
    action service_actions(new_resource)
  end
end

action :delete do
  systemd_unit "#{new_resource.service_name}.service" do
    action %i(stop disable delete)
  end

  file environment_file_path(new_resource) do
    action :delete
  end

  link new_resource.install_dir do
    action :delete
  end

  [new_resource.version_install_dir, new_resource.log_dir, *kafka_log_dirs(new_resource)].uniq.each do |managed_directory|
    directory managed_directory do
      recursive true
      action :delete
    end
  end

  file cached_archive_path(new_resource) do
    action :delete
  end
end
