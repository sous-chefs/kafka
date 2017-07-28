#
# Cookbook Name:: kafka
# Recipe:: _install
#

md5 = node['kafka']['md5_checksum']
sha256 = node['kafka']['checksum']

remote_file kafka_local_download_path do
  source kafka_download_uri(kafka_tar_gz)
  mode '644'
  checksum sha256 if sha256 && !sha256.empty?
  notifies :create, 'ruby_block[kafka-validate-download]', :immediately
  not_if { kafka_installed? }
end

ruby_block 'kafka-validate-download' do
  block do
    if md5 && !md5.empty?
      unless (checksum = Digest::MD5.file(local_file_path).hexdigest) == md5.downcase
        Chef::Application.fatal! %(Downloaded tarball checksum (#{checksum}) does not match provided checksum (#{md5}))
      end
    else
      Chef::Log.debug 'No MD5 checksum set, not validating downloaded archive'
    end
  end
  action :nothing
  not_if { kafka_installed? }
end

execute 'extract-kafka' do
  cwd node['kafka']['build_dir']
  command <<-EOH.gsub(/^\s+/, '')
    tar zxf #{kafka_local_download_path} && \
    chown -R #{node['kafka']['user']}:#{node['kafka']['group']} #{node['kafka']['build_dir']}
  EOH
  not_if { kafka_installed? }
end

execute 'install-kafka' do
  command %(cp -rp #{::File.join(kafka_target_path, '*')} #{node['kafka']['version_install_dir']})
  not_if { kafka_installed? }
end

execute 'remove-kafka-build' do
  command %(rm -rf #{kafka_target_path})
  not_if { kafka_installed? }
end

link node['kafka']['install_dir'] do
  owner node['kafka']['user']
  group node['kafka']['group']
  to node['kafka']['version_install_dir']
end
