#
# Cookbook Name:: kafka
# Recipe:: source
#

node.default[:kafka][:scala_version] ||= '2.9.2'
node.default[:kafka][:checksum]      ||= '123c72a6d7562db836c71362ae9c6bc21e9549cf20c97cccf9acef0a83118f74'
node.default[:kafka][:md5_checksum]  ||= '81f1d7067c9848ecacebb16561b992d4'

kafka_tar_gz      = [kafka_src, kafka_archive_ext].join('.')
local_file_path   = ::File.join(Chef::Config[:file_cache_path], kafka_tar_gz)

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
    #{kafka_build_command}
  EOH
  not_if { kafka_installed? }
end

execute 'extract-kafka' do
  cwd ::File.dirname(kafka_target_path)
  command %(tar zxf #{kafka_base}.#{kafka_archive_ext})
  only_if { !kafka_installed? && node[:kafka][:version] == '0.8.1' }
end

kafka_install node[:kafka][:install_dir] do
  from kafka_target_path
  not_if { kafka_installed? }
end
