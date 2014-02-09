#
# Cookbook Name:: kafka
# Recipe:: source
#

node.default[:kafka][:scala_version] ||= '2.9.2'
node.default[:kafka][:checksum]      ||= 'f4b7229671aba98dba9a882244cb597aab8a9018631575d28e119725a01cfc9a'
node.default[:kafka][:md5_checksum]  ||= '46b3e65e38f1bde4b6251ea131d905f4'

kafka_src         = %(kafka-#{node[:kafka][:version]}-src)
kafka_tar_gz      = %(#{kafka_src}.tgz)
local_file_path   = ::File.join(Chef::Config[:file_cache_path], kafka_tar_gz)
kafka_target_path = ::File.join(node[:kafka][:build_dir], kafka_src, 'target', 'RELEASE', kafka_base)

kafka_download local_file_path do
  source kafka_download_uri(kafka_tar_gz)
  checksum node[:kafka][:checksum]
  md5_checksum node[:kafka][:md5_checksum]
  not_if { kafka_installed? }
end

execute 'compile-kafka' do
  cwd node[:kafka][:build_dir]
  command <<-EOH.gsub(/^\s+/, '')
    tar zxf #{local_file_path} && \
    cd #{kafka_src} && \
    ./sbt update && \
    ./sbt '++#{node[:kafka][:scala_version]} release-zip'
  EOH
  not_if { kafka_installed? }
end

kafka_install node[:kafka][:install_dir] do
  from kafka_target_path
  not_if { kafka_installed? }
end
