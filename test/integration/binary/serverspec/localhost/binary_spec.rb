# encoding: utf-8

require 'spec_helper'
require 'install_common'

describe 'kafka::binary' do
  it_behaves_like 'an install method' do
    let :kafka_archive_path do
      '/tmp/kitchen/cache/kafka_2.9.2-0.8.1.tar.gz'
    end

    let :kafka_archive_md5checksum do
      'bf0296ae67124a76966467e56d01de3e'
    end

    let :jar_path do
      '/opt/kafka/libs/kafka_2.9.2-0.8.1.jar'
    end
  end
end
