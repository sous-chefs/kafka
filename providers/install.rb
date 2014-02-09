#
# Cookbook Name:: kafka
# Provider:: install
#

action :run do
  execute 'install-kafka' do
    user  node[:kafka][:user]
    group node[:kafka][:group]
    command <<-EOH.gsub(/^\s+/, '')
      cp -r #{::File.join(new_resource.from, '*')} #{new_resource.to} && \
      rm -rf #{::File.join(new_resource.from, '*')}
    EOH
  end
end
