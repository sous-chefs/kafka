#
# Cookbook Name:: kafka
# Libraries:: kafka_helpers
#

def kafka_base
  %(kafka_#{node[:kafka][:scala_version]}-#{node[:kafka][:version]})
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

def zookeeper_connect_string
  connect_string = node[:kafka][:zookeeper][:connect].join(',')

  if node[:kafka][:zookeeper][:path] && !node[:kafka][:zookeeper][:path].empty?
    connect_string << '/' unless node[:kafka][:zookeeper][:path].start_with?('/')
    connect_string << node[:kafka][:zookeeper][:path]
  end

  connect_string
end
