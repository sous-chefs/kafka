# encoding: utf-8

use_inline_resources

action :run do
  execute 'install-kafka' do
    user  node[:kafka][:user]
    group node[:kafka][:group]
    command <<-EOH.gsub(/^\s+/, '')
      cp -r #{::File.join(new_resource.from, '*')} #{new_resource.to} && \
      rm -rf #{new_resource.from}
    EOH
  end
end
