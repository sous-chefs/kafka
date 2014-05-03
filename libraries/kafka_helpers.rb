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
  if kafka_binary_install?
    ::File.join(node[:kafka][:build_dir], kafka_base)
  else
    if kafka_v0_8_0?
      ::File.join(node[:kafka][:build_dir], kafka_src, 'target', 'RELEASE', kafka_base)
    else
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
  if kafka_v0_8_0? && kafka_binary_install?
    'tar.gz'
  else
    'tgz'
  end
end

def kafka_build_command
  if kafka_v0_8_0?
    %(./sbt update && ./sbt "++#{node[:kafka][:scala_version]} release-zip")
  else
    %(./gradlew -PscalaVersion=#{node[:kafka][:scala_version]} releaseTarGz -x signArchives)
  end
end

def kafka_v0_8_0?
  node[:kafka][:version] == '0.8.0'
end

def kafka_install_method
  node[:kafka][:install_method].to_sym
end

def kafka_binary_install?
  kafka_install_method == :binary
end

def zookeeper_connect_string
  connect_string = node[:kafka][:zookeeper][:connect].join(',')

  if node[:kafka][:zookeeper][:path] && !node[:kafka][:zookeeper][:path].empty?
    connect_string << '/' unless node[:kafka][:zookeeper][:path].start_with?('/')
    connect_string << node[:kafka][:zookeeper][:path]
  end

  connect_string
end
