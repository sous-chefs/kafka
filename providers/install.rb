#
# Cookbook Name:: kafka
# Provider:: install
#

use_inline_resources

action :run do
  execute 'install-kafka' do
    user  node.kafka.user
    group node.kafka.group
    command %(cp -r #{::File.join(new_resource.from, '*')} #{new_resource.to})
  end

  execute 'remove-kafka-build' do
    command %(rm -rf #{new_resource.from})
  end

  new_resource.updated_by_last_action(true)
end
