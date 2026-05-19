# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_install' do
  step_into :kafka_install
  platform 'ubuntu', '24.04'

  context 'with default properties' do
    recipe do
      kafka_install 'default'
    end

    let(:archive_path) { ::File.join(Chef::Config[:file_cache_path], 'kafka_2.13-4.2.0.tgz') }
    let(:build_dir) { ::File.join(Chef::Config[:file_cache_path], 'kafka-build') }

    it { is_expected.to create_directory(build_dir) }
    it { is_expected.to create_remote_file(archive_path).with(source: 'https://downloads.apache.org/kafka/4.2.0/kafka_2.13-4.2.0.tgz') }
    it { is_expected.to create_directory('/opt/kafka-4.2.0') }
    it { is_expected.to run_execute('install kafka_2.13-4.2.0') }
    it { is_expected.to create_link('/opt/kafka').with(to: '/opt/kafka-4.2.0') }
  end

  context 'action :delete' do
    recipe do
      kafka_install 'default' do
        action :delete
      end
    end

    it { is_expected.to delete_link('/opt/kafka') }
    it { is_expected.to delete_directory('/opt/kafka-4.2.0') }
  end
end
