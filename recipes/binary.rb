#
# Cookbook Name:: kafka
# Recipe:: binary
#

node.default[:kafka][:scala_version] ||= '2.8.0'
node.default[:kafka][:checksum]      ||= 'ecadd6cf9f59e22444af5888c8b9595c5652ffab597db038418e85dfa834062e'
node.default[:kafka][:md5_checksum]  ||= '593e0cf966e6b8cd1bbff5bff713c4b3'

kafka_tar_gz      = "#{kafka_base}.tar.gz"
local_file_path   = File.join(Chef::Config[:file_cache_path], kafka_tar_gz)
build_directory   = File.join(node[:kafka][:install_dir], 'build')
kafka_target_path = File.join(build_directory, kafka_base)
installed_path    = File.join(node[:kafka][:install_dir], "#{kafka_base}.jar")

remote_file local_file_path do
  source   kafka_download_uri(kafka_tar_gz)
  mode     '644'
  checksum node[:kafka][:checksum]
  notifies :create, 'ruby_block[validate-tarball]', :immediately
  not_if { kafka_already_installed? }
end

ruby_block 'validate-tarball' do
  block do
    unless (checksum = Digest::MD5.file(local_file_path).hexdigest) == node[:kafka][:md5_checksum]
      Chef::Application.fatal!("Downloaded tarball checksum (#{checksum}) does not match known checksum (#{node[:kafka][:md5_checksum]})")
    end
  end
  action :nothing
  notifies :run, 'execute[extract-kafka]', :immediately
end

execute 'extract-kafka' do
  user     node[:kafka][:user]
  group    node[:kafka][:group]
  cwd      build_directory
  command  %{tar zxf #{local_file_path}}
  action   :nothing
  notifies :run, 'execute[install-kafka]', :immediately
end

execute 'install-kafka' do
  user  node[:kafka][:user]
  group node[:kafka][:group]
  cwd   node[:kafka][:install_dir]
  command %{cp -r #{File.join(kafka_target_path, '*')} .}
  action :nothing
end
