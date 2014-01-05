#
# Cookbook Name:: kafka
# Recipe:: binary
#

node.default[:kafka][:scala_version] ||= '2.8.0'
node.default[:kafka][:checksum]      ||= 'ecadd6cf9f59e22444af5888c8b9595c5652ffab597db038418e85dfa834062e'
node.default[:kafka][:md5_checksum]  ||= '593e0cf966e6b8cd1bbff5bff713c4b3'

kafka_base        = "kafka_#{node[:kafka][:scala_version]}-#{node[:kafka][:version]}"
kafka_tar_gz      = "#{kafka_base}.tar.gz"
download_file     = "#{node[:kafka][:base_url]}/#{node[:kafka][:version]}/#{kafka_tar_gz}"
local_file_path   = File.join(Chef::Config[:file_cache_path], kafka_tar_gz)
dist_directory    = File.join(node[:kafka][:install_dir], 'dist')
kafka_target_path = File.join(dist_directory, kafka_base)
installed_path    = File.join(node[:kafka][:install_dir], "#{kafka_base}.jar")

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
    cwd      dist_directory
    command  %{tar zxvf #{local_file_path}}
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
end
