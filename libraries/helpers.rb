#
# Cookbook Name:: kafka
# Libraries:: helpers
#

def kafka_base
  %(kafka_#{node['kafka']['scala_version']}-#{node['kafka']['version']})
end

def kafka_tar_gz
  [kafka_base, 'tgz'].join('.')
end

def kafka_local_download_path
  ::File.join(Chef::Config.file_cache_path, kafka_tar_gz)
end

def kafka_target_path
  ::File.join(node['kafka']['build_dir'], kafka_base)
end

def kafka_jar_path
  ::File.join(node['kafka']['install_dir'], 'libs', %(#{kafka_base}.jar))
end

def kafka_installed?
  ::File.exist?(node['kafka']['install_dir']) && ::File.exist?(kafka_jar_path)
end

def kafka_download_uri(filename)
  [node['kafka']['base_url'], node['kafka']['version'], filename].join('/')
end

def kafka_init_style
  node['kafka']['init_style'].to_sym
end

def kafka_init_opts
  @kafka_init_opts ||= {}.tap do |opts|
    case kafka_init_style
    when :sysv
      opts[:env_path] = value_for_platform_family(
        'debian' => '/etc/default/kafka',
        'default' => '/etc/sysconfig/kafka',
      )
      opts[:source] = value_for_platform_family(
        'debian' => 'sysv/debian.erb',
        'default' => 'sysv/default.erb',
      )
      opts[:script_path] = '/etc/init.d/kafka'
      opts[:permissions] = '755'
    when :upstart
      opts[:env_path] = '/etc/default/kafka'
      opts[:source] = value_for_platform_family(
        'default' => 'upstart/default.erb',
      )
      opts[:script_path] = '/etc/init/kafka.conf'
      opts[:provider] = ::Chef::Provider::Service::Upstart
      opts[:permissions] = '644'
    when :systemd
      opts[:env_path] = value_for_platform_family(
        'debian' => '/etc/default/kafka',
        'default' => '/etc/sysconfig/kafka',
      )
      opts[:source] = value_for_platform_family(
        'default' => 'systemd/default.erb',
      )
      opts[:script_path] = '/etc/systemd/system/kafka.service'
      opts[:provider] = ::Chef::Provider::Service::Systemd
      opts[:permissions] = '644'
    end
  end
end

def start_automatically?
  !!node['kafka']['automatic_start'] || restart_on_configuration_change?
end

def restart_on_configuration_change?
  !!node['kafka']['automatic_restart']
end

def kafka_service_actions
  actions = [:enable]
  actions << :start if start_automatically?
  actions
end

def kafka_log_dirs
  dirs = []
  dirs += Array(node['kafka']['broker']['log.dirs'])
  dirs += Array(node['kafka']['broker'].fetch(:log_dirs, []))
  dirs += Array(node['kafka']['broker'].fetch(:log, {}).fetch(:dirs, []))
  dirs.uniq!
  dirs
end

def broker_attribute?(*parts)
  parts = parts.map(&:to_s)
  broker = node['kafka']['broker']
  if broker.attribute?(parts.join('.')) || broker.attribute?(parts.join('_'))
    true
  else
    key = parts.pop
    r = parts.reduce(broker) { |a, e| a.fetch(e, a) }
    r.attribute?(key)
  end
end

def fetch_broker_attribute(*parts)
  parts = parts.map(&:to_s)
  broker = node['kafka']['broker']
  if broker.attribute?(parts.join('.'))
    broker[parts.join('.')]
  elsif broker.attribute?(parts.join('_'))
    broker[parts.join('_')]
  else
    key = parts.pop
    r = parts.reduce(broker) { |a, e| a.fetch(e, a) }
    r[key]
  end
end
