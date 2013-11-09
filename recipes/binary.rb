#
# Cookbook Name:: kafka
# Recipe:: binary
#

include_recipe 'kafka::configure'

node.default[:kafka][:scala_version] ||= '2.8.0'
node.default[:kafka][:checksum]      ||= '750046ab729d2dbc1d5756794ebf8fcb640879b23a64749164c43063286316b8'
node.default[:kafka][:md5_checksum]  ||= 'f12e7698aff37a0e014cb9dc087f0b8f'

kafka_base      = "kafka_#{node[:kafka][:scala_version]}-#{node[:kafka][:version]}"
kafka_tar_gz    = "#{kafka_base}.tgz"
download_file   = "#{node[:kafka][:base_url]}/#{kafka_tar_gz}"
local_file_path = "#{Chef::Config[:file_cache_path]}/#{kafka_tar_gz}"
dist_directory  = "#{node[:kafka][:install_dir]}/dist"
kafka_jar       = "#{kafka_base}.jar"
kafka_jar_path  = "#{node[:kafka][:install_dir]}/dist/#{kafka_base}/#{kafka_jar}"
kafka_libs_path = "#{node[:kafka][:install_dir]}/dist/#{kafka_base}/libs"
installed_path  = "#{node[:kafka][:install_dir]}/#{kafka_jar}"

unless (already_installed = (File.directory?(dist_directory) && File.exists?(installed_path)))
  directory dist_directory do
    owner     node[:kafka][:user]
    group     node[:kafka][:group]
    mode      '755'
    action    :create
    recursive true
  end

  remote_file local_file_path do
    source   download_file
    mode     '644'
    checksum node[:kafka][:checksum]
    notifies :create, 'ruby_block[validate-tarball]', :immediately
  end

  ruby_block 'validate-tarball' do
    block do
      checksum = Digest::MD5.file(local_file_path).hexdigest
      unless checksum == node[:kafka][:md5_checksum]
        Chef::Log.fatal!("Downloaded tarball checksum (#{checksum}) does not match known checksum (#{node[:kafka][:md5_checksum]})")
      end
    end
    action :nothing
    notifies :run, 'execute[extract-kafka]', :immediately
  end

  execute 'extract-kafka' do
    cwd      dist_directory
    command  %{tar zxvf #{local_file_path}}
    action   :nothing
    notifies :run, 'execute[install-kafka]', :immediately
  end

  execute 'install-kafka' do
    user  node[:kafka][:user]
    group node[:kafka][:group]
    cwd   node[:kafka][:install_dir]
    command %{cp -r #{kafka_libs_path} . && cp #{kafka_jar_path} .}
    action :nothing
  end
end
