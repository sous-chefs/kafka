#
# Cookbook Name:: kafka
# Recipe:: source
#

kafka_tar_gz = [kafka_src, kafka_archive_ext].join('.')
local_file_path = ::File.join(Chef::Config.file_cache_path, kafka_tar_gz)

kafka_download local_file_path do
  source kafka_download_uri(kafka_tar_gz)
  checksum node.kafka.checksum
  md5_checksum node.kafka.md5_checksum
  not_if { kafka_installed? }
end

execute 'compile-kafka' do
  cwd node.kafka.build_dir
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
  only_if { !kafka_installed? && !kafka_v0_8_0? }
end

kafka_install node.kafka.install_dir do
  from kafka_target_path
  not_if { kafka_installed? }
end
