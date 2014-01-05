#
# Cookbook Name:: kafka
# Recipe:: source
#

node.default[:kafka][:scala_version] ||= '2.9.2'
node.default[:kafka][:checksum]      ||= 'f4b7229671aba98dba9a882244cb597aab8a9018631575d28e119725a01cfc9a'
node.default[:kafka][:md5_checksum]  ||= '46b3e65e38f1bde4b6251ea131d905f4'

kafka_src          = "kafka-#{node[:kafka][:version]}-src"
kafka_base         = "kafka_#{node[:kafka][:scala_version]}-#{node[:kafka][:version]}"
kafka_tar_gz       = "#{kafka_src}.tgz"
download_file      = "#{node[:kafka][:base_url]}/#{node[:kafka][:version]}/#{kafka_tar_gz}"
build_directory    = File.join(node[:kafka][:install_dir], 'build')
local_file_path    = File.join(Chef::Config[:file_cache_path], kafka_tar_gz)
kafka_target_path  = File.join(build_directory, kafka_src, 'target', 'RELEASE', kafka_base)
installed_path     = File.join(node[:kafka][:install_dir], "#{kafka_base}.jar")

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
      unless (checksum = Digest::MD5.file(local_file_path).hexdigest) == node[:kafka][:md5_checksum]
        Chef::Application.fatal!("Downloaded tarball checksum (#{checksum}) does not match known checksum (#{node[:kafka][:md5_checksum]})")
      end
    end
    action :nothing
    notifies :run, 'execute[compile-kafka]', :immediately
  end

  execute 'compile-kafka' do
    cwd   build_directory
    command <<-EOH.gsub(/^\s+/, '')
      tar zxvf #{local_file_path}
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
    command %{cp -r #{File.join(kafka_target_path, '*')} .}
    action :nothing
  end
end
