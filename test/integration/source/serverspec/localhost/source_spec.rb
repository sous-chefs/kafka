# encoding: utf-8

require 'spec_helper'
require 'install_common'

describe 'kafka::source' do
  it_behaves_like 'an install method' do
    let :kafka_archive_path do
      '/tmp/kitchen/cache/kafka-0.8.1-src.tgz'
    end

    let :kafka_archive_md5checksum do
      '7174f7855cb2f7e131799cb23805cd35'
    end

    let :jar_path do
      '/opt/kafka/libs/kafka_2.9.2-0.8.1.jar'
    end
  end
end
