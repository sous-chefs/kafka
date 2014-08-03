#
# Cookbook Name:: kafka
# Libraries:: helpers
#

def kafka_base
  %(kafka_#{node.kafka.scala_version}-#{node.kafka.version})
end

def kafka_src
  %(kafka-#{node.kafka.version}-src)
end

def kafka_target_path
  if kafka_binary_install?
    ::File.join(node.kafka.build_dir, kafka_base)
  else
    if kafka_v0_8_0?
      ::File.join(node.kafka.build_dir, kafka_src, 'target', 'RELEASE', kafka_base)
    else
      ::File.join(node.kafka.build_dir, kafka_src, 'core', 'build', 'distributions', kafka_base)
    end
  end
end

def kafka_jar_path
  if kafka_v0_8_0?
    ::File.join(node.kafka.install_dir, %(#{kafka_base}.jar))
  else
    ::File.join(node.kafka.install_dir, 'libs', %(#{kafka_base}.jar))
  end
end

def kafka_installed?
  ::File.exists?(node.kafka.install_dir) && ::File.exists?(kafka_jar_path)
end

def kafka_download_uri(filename)
  [node.kafka.base_url, node.kafka.version, filename].join('/')
end

def kafka_archive_ext
  if kafka_v0_8_0? && kafka_binary_install?
    'tar.gz'
  else
    'tgz'
  end
end

def kafka_build_command
  if kafka_v0_8_0?
    %(./sbt update && ./sbt "++#{node.kafka.scala_version} release-zip")
  else
    %(./gradlew -PscalaVersion=#{node.kafka.scala_version} releaseTarGz -x signArchives)
  end
end

def kafka_v0_8_0?
  node.kafka.version == '0.8.0'
end

def kafka_install_method
  node.kafka.install_method.to_sym
end

def kafka_init_style
  node.kafka.init_style.to_sym
end

def kafka_binary_install?
  kafka_install_method == :binary
end

def kafka_init_opts
  @kafka_init_opts ||= Hash.new.tap do |opts|
    case kafka_init_style
    when :sysv
      opts[:env_path] = value_for_platform_family({
        'debian' => '/etc/default/kafka',
        'default' => '/etc/sysconfig/kafka',
      })
      opts[:source] = value_for_platform_family({
        'debian' => 'sysv/debian.erb',
        'default' => 'sysv/default.erb',
      })
      opts[:script_path] = '/etc/init.d/kafka'
      opts[:permissions] = '755'
    when :upstart
      opts[:env_path] = '/etc/default/kafka'
      opts[:source] = value_for_platform_family({
        'default' => 'upstart/default.erb',
      })
      opts[:script_path] = '/etc/init/kafka.conf'
      opts[:provider] = ::Chef::Provider::Service::Upstart
      opts[:permissions] = '644'
    end
  end
end

def start_automatically?
  !!node.kafka.automatic_start || restart_on_configuration_change?
end

def restart_on_configuration_change?
  !!node.kafka.automatic_restart
end

def kafka_service_actions
  actions = [:enable]
  actions << :start if start_automatically?
  actions
end
