#
# Cookbook Name:: kafka
# Recipe:: binary
#

kafka_tar_gz = [kafka_base, kafka_archive_ext].join('.')
local_file_path = ::File.join(Chef::Config.file_cache_path, kafka_tar_gz)

kafka_download local_file_path do
  source kafka_download_uri(kafka_tar_gz)
  checksum node.kafka.checksum
  md5_checksum node.kafka.md5_checksum
  not_if { kafka_installed? }
end

execute 'extract-kafka' do
  user 'root'
  group 'root'
  cwd node.kafka.build_dir
  command <<-EOH.gsub(/^\s+/, '')
    tar zxf #{local_file_path} && \
    chown -R #{node.kafka.user}:#{node.kafka.group} #{node.kafka.build_dir}
  EOH
  not_if { kafka_installed? }
end

kafka_install node.kafka.install_dir do
  from kafka_target_path
  not_if { kafka_installed? }
end
