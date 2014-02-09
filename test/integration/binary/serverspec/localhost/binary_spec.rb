# encoding: utf-8

require 'spec_helper'
require 'install_common'

describe 'kafka::binary' do
  it_behaves_like 'an install method' do
    let :kafka_archive_path do
      '/tmp/kitchen/cache/kafka_2.8.0-0.8.0.tar.gz'
    end

    let :kafka_archive_md5checksum do
      '593e0cf966e6b8cd1bbff5bff713c4b3'
    end

    let :jar_path do
      '/opt/kafka/kafka_2.8.0-0.8.0.jar'
    end
  end
end
