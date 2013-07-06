#
# Cookbook Name:: kafka
# Recipe:: source
#
# Copyright 2013, Burt
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'kafka::default'

node[:kafka][:checksum] = 'e069a1d5e47d18944376b6ca30b625dc013045e7e1f948054ef3789a4b5f54b3'

kafka_src = "kafka-#{node[:kafka][:version]}-src"
kafka_tar_gz = "#{kafka_src}.tgz"
download_file = "#{node[:kafka][:base_url]}/#{kafka_tar_gz}"
local_file_path = "#{Chef::Config[:file_cache_path]}/#{kafka_tar_gz}"

directory("#{node[:kafka][:install_dir]}/build") do
  owner 'root'
  group 'root'
  mode 00644
  action :create
  recursive true
  not_if { File.exists?("#{node[:kafka][:install_dir]}/build") }
end

directory("#{node[:kafka][:install_dir]}/libs") do
  owner 'root'
  group 'root'
  mode 00644
  action :create
  recursive true
  not_if { File.exists?("#{node[:kafka][:install_dir]}/libs") }
end

remote_file(local_file_path) do
  source download_file
  mode 00644
  checksum node[:kafka][:checksum]
end

kafka_path = "kafka_#{node[:kafka][:scala_version]}-#{node[:kafka][:version]}"
kafka_jar = "#{kafka_path}.jar"
kafka_release_path = "#{node[:kafka][:install_dir]}/build/#{kafka_src}/target/RELEASE"
kafka_jar_path = File.join(kafka_release_path, kafka_path, kafka_jar)
kafka_libs_path = File.join(kafka_release_path, kafka_path, 'libs')

bash 'compile-kafka' do
  cwd "#{node[:kafka][:install_dir]}/build"
  # EOH = End-Of-Hell
  code <<-EOH
    tar zxvf #{Chef::Config[:file_cache_path]}/#{kafka_tar_gz}
    cd #{kafka_src}
    ./sbt update
    ./sbt "++#{node[:kafka][:scala_version]} release-zip"
  EOH

  not_if { [kafka_release_path, kafka_jar_path, kafka_libs_path].all? { |p| File.exists?(p) } }
end

bash 'install-kafka' do
  cwd "#{node[:kafka][:install_dir]}"
  code <<-EOH
    cp #{kafka_jar_path} .
    cp -r #{kafka_libs_path} .
  EOH
end
