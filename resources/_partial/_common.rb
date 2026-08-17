# frozen_string_literal: true

property :instance_name, String, name_property: true

property :user, String, default: 'kafka'
property :group, String, default: 'kafka'
property :manage_user, [true, false], default: true
property :uid, [Integer, String, nil], default: nil
property :gid, [Integer, String, nil], default: nil

property :version, String, default: '4.2.1'
property :scala_version, String, default: '2.13'
property :base_url, String, default: 'https://downloads.apache.org/kafka'

property :checksum, [String, nil], default: nil
property :md5_checksum, [String, nil], default: nil
property :sha512_checksum, [String, nil],
         default: 'f643e31266268e920aa98ead9a061026c98dac2886932ad468565ba59bcb7fb4f98a4c4f62727367e1bd87515f3b016e6f6ccccad8b12bdef8b091b0fb577170'

property :install_dir, String, default: '/opt/kafka'
property :version_install_dir, String, default: lazy { "#{install_dir}-#{version}" }
property :build_dir, String, default: lazy { ::File.join(Chef::Config[:file_cache_path], 'kafka-build') }
property :config_dir, String, default: lazy { ::File.join(install_dir, 'config') }
property :log_dir, String, default: '/var/log/kafka'
