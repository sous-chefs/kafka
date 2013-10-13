#
# Cookbook Name:: kafka
# Recipe:: binary
#

include_recipe 'kafka::default'

node[:kafka][:scala_version] ||= '2.8.0'
node[:kafka][:checksum]      ||= '750046ab729d2dbc1d5756794ebf8fcb640879b23a64749164c43063286316b8'

kafka_base      = "kafka_#{node[:kafka][:scala_version]}-#{node[:kafka][:version]}"
kafka_tar_gz    = "#{kafka_base}.tgz"
download_file   = "#{node[:kafka][:base_url]}/#{kafka_tar_gz}"
local_file_path = File.join(Chef::Config[:file_cache_path]}, kafka_tar_gz)
dist_directory  = File.join(node[:kafka][:install_dir], 'dist')
kafka_jar       = "#{kafka_base}.jar"
kafka_jar_path  = File.join(node[:kafka][:install_dir], 'dist', kafka_base, kafka_jar)
kafka_libs_path = File.join(node[:kafka][:install_dir], 'dist', kafka_base, 'libs')

directory(dist_directory) do
  owner     node[:kafka][:user]
  group     node[:kafka][:group]
  mode      '755'
  action    :create
  recursive true
end

remote_file(local_file_path) do
  source   download_file
  mode     '644'
  checksum node[:kafka][:checksum]
end

bash 'extract-kafka' do
  cwd  dist_directory # "#{node[:kafka][:install_dir]}/dist"
  code "tar zxvf #{File.join(Chef::Config[:file_cache_path], kafka_tar_gz)}"
end

bash 'install-kafka' do
  cwd node[:kafka][:install_dir]
  code <<-EOH
    cp #{kafka_jar_path} .
    cp -r #{kafka_libs_path} .
  EOH
end
