#
# Cookbook Name:: kafka
# Provider:: download
#

use_inline_resources

action :create do
  local_file_path = new_resource.name
  known_md5 = new_resource.md5_checksum
  sha256 = new_resource.checksum

  remote_file local_file_path do
    source   new_resource.source
    mode     new_resource.mode
    checksum sha256 if sha256 && !sha256.empty?
    notifies :create, 'ruby_block[kafka-validate-download]', :immediately
  end

  ruby_block 'kafka-validate-download' do
    block do
      if known_md5 && !known_md5.empty?
        unless (checksum = Digest::MD5.file(local_file_path).hexdigest) == known_md5.downcase
          Chef::Application.fatal! %(Downloaded tarball checksum (#{checksum}) does not match known checksum (#{known_md5}))
        end
      else
        Chef::Log.debug 'No MD5 checksum set, not validating downloaded archive'
      end

      new_resource.updated_by_last_action(true)
    end
    action :nothing
  end
end
