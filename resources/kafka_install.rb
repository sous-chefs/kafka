# frozen_string_literal: true

provides :kafka_install
unified_mode true

use '_partial/_common'

action_class do
  include Kafka::Helpers
end

action :install do
  package 'tar'

  directory new_resource.build_dir do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
  end

  remote_file kafka_archive_path do
    source kafka_download_url
    mode '0644'
    checksum new_resource.checksum if new_resource.checksum
    notifies :run, "ruby_block[validate #{kafka_archive_name}]", :immediately
    not_if { kafka_installed? }
  end

  ruby_block "validate #{kafka_archive_name}" do
    block do
      kafka_validate_checksum!(kafka_archive_path, 'MD5', new_resource.md5_checksum)
      kafka_validate_checksum!(kafka_archive_path, 'SHA512', new_resource.sha512_checksum)
    end
    action :nothing
  end

  directory new_resource.version_install_dir do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
  end

  execute "install #{kafka_version_name}" do
    cwd new_resource.build_dir
    command [
      "tar zxf #{kafka_archive_path}",
      "chown -R #{new_resource.user}:#{new_resource.group} #{::File.join(new_resource.build_dir, kafka_version_name)}",
      "cp -rp #{::File.join(new_resource.build_dir, kafka_version_name, '*')} #{new_resource.version_install_dir}",
      "rm -rf #{::File.join(new_resource.build_dir, kafka_version_name)}",
    ].join(' && ')
    not_if { kafka_installed? }
  end

  link new_resource.install_dir do
    owner new_resource.user
    group new_resource.group
    to new_resource.version_install_dir
  end
end

action :delete do
  link new_resource.install_dir do
    action :delete
  end

  directory new_resource.version_install_dir do
    recursive true
    action :delete
  end

  directory new_resource.build_dir do
    recursive true
    action :delete
  end

  file kafka_archive_path do
    action :delete
  end
end
