#
# Cookbook Name:: kafka
# Recipe:: source
#

include_recipe 'kafka::configure'

node.default[:kafka][:scala_version] ||= '2.9.2'
node.default[:kafka][:checksum]      ||= 'e069a1d5e47d18944376b6ca30b625dc013045e7e1f948054ef3789a4b5f54b3'
node.default[:kafka][:md5_checksum]  ||= 'b90e355ea2bc1e5f62db1836fdd77502'

build_directory    = "#{node[:kafka][:install_dir]}/build"
kafka_src          = "kafka-#{node[:kafka][:version]}-src"
kafka_tar_gz       = "#{kafka_src}.tgz"
download_file      = "#{node[:kafka][:base_url]}/#{kafka_tar_gz}"
local_file_path    = "#{Chef::Config[:file_cache_path]}/#{kafka_tar_gz}"
kafka_path         = "kafka_#{node[:kafka][:scala_version]}-#{node[:kafka][:version]}"
kafka_jar          = "#{kafka_path}.jar"
kafka_release_path = "#{build_directory}/#{kafka_src}/target/RELEASE"
kafka_jar_path     = "#{kafka_release_path}/#{kafka_path}/#{kafka_jar}"
kafka_libs_path    = "#{kafka_release_path}/#{kafka_path}/libs"
installed_path     = "#{node[:kafka][:install_dir]}/#{kafka_jar}"

unless (already_installed = (File.directory?(build_directory) && File.exists?(installed_path)))
  directory build_directory do
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
    notifies :run, 'execute[compile-kafka]', :immediately
  end

  execute 'compile-kafka' do
    cwd   build_directory
    command <<-EOH.gsub(/^\s+/, '')
      tar zxvf #{Chef::Config[:file_cache_path]}/#{kafka_tar_gz}
      cd #{kafka_src}
      ./sbt update
      ./sbt "++#{node[:kafka][:scala_version]} release-zip"
    EOH

    action :nothing
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
