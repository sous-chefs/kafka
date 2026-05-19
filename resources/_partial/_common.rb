# frozen_string_literal: true

property :instance_name, String, name_property: true

property :user, String, default: 'kafka'
property :group, String, default: 'kafka'
property :manage_user, [true, false], default: true
property :uid, [Integer, String, nil], default: nil
property :gid, [Integer, String, nil], default: nil

property :version, String, default: '4.2.0'
property :scala_version, String, default: '2.13'
property :base_url, String, default: 'https://downloads.apache.org/kafka'

property :checksum, [String, nil], default: nil
property :md5_checksum, [String, nil], default: nil
property :sha512_checksum, [String, nil],
         default: '16ce46e590ba915f01b720ea514445e49c88bf129cf4ceab88878b122d54ef24f0dedb88d0eb178957f58057a6c6a9adbea8b8059307585daea13129b85ba1d8'

property :install_dir, String, default: '/opt/kafka'
property :version_install_dir, String, default: lazy { "#{install_dir}-#{version}" }
property :build_dir, String, default: lazy { ::File.join(Chef::Config[:file_cache_path], 'kafka-build') }
property :config_dir, String, default: lazy { ::File.join(install_dir, 'config') }
property :log_dir, String, default: '/var/log/kafka'
