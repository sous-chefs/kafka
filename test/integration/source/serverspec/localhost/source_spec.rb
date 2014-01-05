# encoding: utf-8

require 'spec_helper'
require 'install_common'

describe 'kafka::source' do
  it_behaves_like 'an install method' do
    let :kafka_archive_path do
      '/tmp/kitchen/cache/kafka-0.8.0-src.tgz'
    end

    let :kafka_archive_md5checksum do
      '46b3e65e38f1bde4b6251ea131d905f4'
    end

    let :jar_path do
      '/opt/kafka/kafka_2.9.2-0.8.0.jar'
    end
  end

  describe '/opt/kafka/build' do
    it_behaves_like 'a kafka directory', skip_files: true do
      let :path do
        '/opt/kafka/build'
      end
    end
  end
end
