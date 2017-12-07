#
# Cookbook Name:: kafka
# Recipe:: _install
#

tar_gz = [kafka_version_name, 'tgz'].join('.')
local_download_path = ::File.join(Chef::Config.file_cache_path, tar_gz)
build_path = ::File.join(node['kafka']['build_dir'], kafka_version_name)
remote_path = [node['kafka']['base_url'], node['kafka']['version'], tar_gz].join('/')
md5 = node['kafka']['md5_checksum']
sha256 = node['kafka']['checksum']
sha512 = node['kafka']['sha512_checksum']

remote_file local_download_path do
  source remote_path
  mode '644'
  checksum sha256 if sha256 && !sha256.empty?
  notifies :create, 'ruby_block[kafka-validate-download]', :immediately
  not_if { kafka_installed? }
end

ruby_block 'kafka-validate-download' do
  block do
    if md5 && !md5.empty?
      unless (checksum = Digest::MD5.file(local_download_path).hexdigest) == md5.downcase
        Chef::Application.fatal! %(Downloaded tarball checksum (#{checksum}) does not match provided checksum (#{md5}))
      end
    elsif sha512 && !sha512.empty?
      unless (checksum = Digest::SHA512.file(local_download_path).hexdigest) == sha512.downcase
        Chef::Application.fatal! %(Downloaded tarball checksum (#{checksum}) does not match provided checksum (#{sha512}))
      end
    else
      Chef::Log.debug 'No MD5 or SHA512 checksum set, not validating downloaded archive'
    end
  end
  action :nothing
end

execute 'kafka-install' do
  cwd node['kafka']['build_dir']
  command <<-EOH.gsub(/^\s+/, '')
    tar zxf #{local_download_path} && \
    chown -R #{node['kafka']['user']}:#{node['kafka']['group']} #{build_path} && \
    cp -rp #{::File.join(build_path, '*')} #{node['kafka']['version_install_dir']} && \
    rm -rf #{build_path}
  EOH
  not_if { kafka_installed? }
end

link node['kafka']['install_dir'] do
  owner node['kafka']['user']
  group node['kafka']['group']
  to node['kafka']['version_install_dir']
end
