#
# Cookbook Name:: kafka
# Recipe:: binary
#

node.default[:kafka][:scala_version] ||= '2.9.2'
node.default[:kafka][:checksum]      ||= '33825206ec02ef5e2538e77dee535899d2d15833266f23d9008d156b2e785e88'
node.default[:kafka][:md5_checksum]  ||= 'bf0296ae67124a76966467e56d01de3e'

kafka_tar_gz      = [kafka_base, kafka_archive_ext].join('.')
local_file_path   = ::File.join(Chef::Config[:file_cache_path], kafka_tar_gz)

kafka_download local_file_path do
  source       kafka_download_uri(kafka_tar_gz)
  checksum     node[:kafka][:checksum]
  md5_checksum node[:kafka][:md5_checksum]
  not_if { kafka_installed? }
end

execute 'extract-kafka' do
  user     node[:kafka][:user]
  group    node[:kafka][:group]
  cwd      node[:kafka][:build_dir]
  command  %(tar zxf #{local_file_path})
  not_if { kafka_installed? }
end

kafka_install node[:kafka][:install_dir] do
  from kafka_target_path
  not_if { kafka_installed? }
end
