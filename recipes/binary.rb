#
# Cookbook Name:: kafka
# Recipe:: binary
#

include_recipe 'kafka::default'

node.default[:kafka][:scala_version] ||= '2.8.0'
node.default[:kafka][:checksum]      ||= '750046ab729d2dbc1d5756794ebf8fcb640879b23a64749164c43063286316b8'

kafka_base      = "kafka_#{node[:kafka][:scala_version]}-#{node[:kafka][:version]}"
kafka_tar_gz    = "#{kafka_base}.tgz"
download_file   = "#{node[:kafka][:base_url]}/#{kafka_tar_gz}"
local_file_path = File.join(Chef::Config[:file_cache_path], kafka_tar_gz)
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
  notifies :run, 'bash[extract-kafka]', :immediately
end

bash 'extract-kafka' do
  cwd  dist_directory
  code "tar zxvf #{Chef::Config[:file_cache_path]}/#{kafka_tar_gz}"
  action :nothing
  notifies :run, 'bash[install-kafka]', :immediately
end

bash 'install-kafka' do
  user  node[:kafka][:user]
  group node[:kafka][:group]
  cwd   node[:kafka][:install_dir]
  code <<-EOH
    cp #{kafka_jar_path} .
    cp -r #{kafka_libs_path} .
  EOH

  action :nothing
end
