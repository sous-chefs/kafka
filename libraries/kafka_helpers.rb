#
# Cookbook Name:: kafka
# Libraries:: kafka_helpers
#

def kafka_base
  %(kafka_#{node[:kafka][:scala_version]}-#{node[:kafka][:version]})
end

def kafka_src
  %(kafka-#{node[:kafka][:version]}-src)
end

def kafka_target_path
  case node[:kafka][:install_method].to_sym
  when :binary
    ::File.join(node[:kafka][:build_dir], kafka_base)
  when :source
    case node[:kafka][:version]
    when '0.8.0'
      ::File.join(node[:kafka][:build_dir], kafka_src, 'target', 'RELEASE', kafka_base)
    when '0.8.1'
      ::File.join(node[:kafka][:build_dir], kafka_src, 'core', 'build', 'distributions', kafka_base)
    end
  end
end

def kafka_jar_path
  ::File.join(node[:kafka][:install_dir], %(#{kafka_base}.jar))
end

def kafka_installed?
  ::File.exists?(node[:kafka][:install_dir]) && ::File.exists?(kafka_jar_path)
end

def kafka_download_uri(filename)
  [node[:kafka][:base_url], node[:kafka][:version], filename].join('/')
end

def kafka_archive_ext
  case node[:kafka][:install_method].to_sym
  when :binary
    case node[:kafka][:version]
    when '0.8.0'
      'tar.gz'
    when '0.8.1'
      'tgz'
    end
  else
    'tgz'
  end
end

def kafka_build_command
  case node[:kafka][:version]
  when '0.8.0'
    %(./sbt update && ./sbt "++#{node[:kafka][:scala_version]} release-zip")
  when '0.8.1'
    %(./gradlew -PscalaVersion=#{node[:kafka][:scala_version]} releaseTarGz -x signArchives)
  end
end

def zookeeper_connect_string
  connect_string = node[:kafka][:zookeeper][:connect].join(',')

  if node[:kafka][:zookeeper][:path] && !node[:kafka][:zookeeper][:path].empty?
    connect_string << '/' unless node[:kafka][:zookeeper][:path].start_with?('/')
    connect_string << node[:kafka][:zookeeper][:path]
  end

  connect_string
end
