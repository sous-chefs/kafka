# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_broker' do
  step_into :kafka_broker
  platform 'ubuntu', '24.04'

  context 'with KRaft storage formatting' do
    recipe do
      kafka_broker 'default' do
        automatic_start true
        format_storage true
        cluster_id 'MkU3OEVBNTcwNTJENDM2Qk'
        broker_config(
          'process.roles' => 'broker,controller',
          'log.dirs' => '/var/lib/kafka/data'
        )
      end
    end

    it { is_expected.to create_group('kafka') }
    it { is_expected.to create_user('kafka') }
    it { is_expected.to create_directory('/var/lib/kafka/data') }
    it { is_expected.to install_kafka_install('default') }
    it { is_expected.to create_kafka_config('default') }
    it { is_expected.to run_execute('format kafka storage for default') }
    it { is_expected.to start_kafka_service('default') }
  end

  context 'without required cluster id' do
    recipe do
      kafka_broker 'default' do
        format_storage true
      end
    end

    it 'raises a validation error' do
      expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed, /cluster_id/)
    end
  end

  context 'action :delete' do
    recipe do
      kafka_broker 'default' do
        broker_config('log.dirs' => '/var/lib/kafka/data')
        action :delete
      end
    end

    it { is_expected.to delete_kafka_service('default') }
    it { is_expected.to delete_kafka_config('default') }
    it { is_expected.to delete_kafka_install('default') }
    it { is_expected.to delete_directory('/var/lib/kafka/data') }
    it { is_expected.to delete_directory('/var/log/kafka') }
  end
end
