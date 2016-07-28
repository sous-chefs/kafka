#
# Cookbook Name:: kafka
# Provider:: install
#

use_inline_resources

action :run do
  execute 'install-kafka' do
    command %(cp -rp #{::File.join(new_resource.from, '*')} #{new_resource.to})
  end

  execute 'remove-kafka-build' do
    command %(rm -rf #{new_resource.from})
  end

  link node['kafka']['install_dir'] do
    owner node['kafka']['user']
    group node['kafka']['group']
    to node['kafka']['version_install_dir']
  end

  new_resource.updated_by_last_action(true)
end
