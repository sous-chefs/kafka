# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'kafka_broker' do
  step_into :kafka_broker
  platform 'ubuntu', '24.04'

  let(:archive_path) { '/var/cache/chef/kafka_2.13-3.9.1.tgz' }

  context 'with a single-node KRaft configuration' do
    recipe do
      kafka_broker 'default' do
        automatic_start true
        cluster_id 'MkU3OEVBNTcwNTJENDM2Qk'
        broker(
          'process.roles' => 'broker,controller',
          'node.id' => 1,
          'controller.quorum.voters' => '1@127.0.0.1:9093',
          'listeners' => 'PLAINTEXT://127.0.0.1:9092,CONTROLLER://127.0.0.1:9093',
          'advertised.listeners' => 'PLAINTEXT://127.0.0.1:9092',
          'listener.security.protocol.map' => 'CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT',
          'controller.listener.names' => 'CONTROLLER',
          'inter.broker.listener.name' => 'PLAINTEXT',
          'log.dirs' => ['/var/lib/kafka/data'],
          'offsets.topic.replication.factor' => 1,
          'transaction.state.log.replication.factor' => 1,
          'transaction.state.log.min.isr' => 1,
          'group.initial.rebalance.delay.ms' => 0
        )
      end
    end

    it { is_expected.to create_group('kafka') }
    it { is_expected.to install_openjdk_install('17').with(install_type: 'package', default: true) }
    it { is_expected.to install_package(%w(tar gzip)) }
    it { is_expected.to create_user('kafka').with(home: '/var/empty/kafka', shell: '/sbin/nologin') }
    it { is_expected.to create_directory('/opt/kafka-3.9.1') }
    it { is_expected.to create_directory('/var/log/kafka') }
    it { is_expected.to create_directory('/var/lib/kafka/data') }

    it do
      is_expected.to create_remote_file(archive_path).with(
        source: 'https://archive.apache.org/dist/kafka/3.9.1/kafka_2.13-3.9.1.tgz'
      )
    end

    it { is_expected.to run_execute('extract-kafka-default') }
    it { is_expected.to create_link('/opt/kafka').with(to: '/opt/kafka-3.9.1') }
    it { is_expected.to create_template('/opt/kafka/config/log4j.properties') }
    it { is_expected.to create_template('/opt/kafka/config/server.properties') }

    it do
      is_expected.to create_file('/etc/default/kafka').with(
        content: /KAFKA_HEAP_OPTS="-Xms1G -Xmx1G"/
      )
    end

    it do
      is_expected.to run_execute('format-kafka-storage-default').with(
        command: '/opt/kafka/bin/kafka-storage.sh format --ignore-formatted --cluster-id MkU3OEVBNTcwNTJENDM2Qk --config /opt/kafka/config/server.properties'
      )
    end

    it { is_expected.to create_systemd_unit('kafka.service') }
    it { is_expected.to enable_systemd_unit('kafka.service') }
    it { is_expected.to start_systemd_unit('kafka.service') }
    it { is_expected.to render_file('/opt/kafka/config/server.properties').with_content(/process\.roles=broker,controller/) }
    it { is_expected.to render_file('/opt/kafka/config/server.properties').with_content(/controller\.quorum\.voters=1@127\.0\.0\.1:9093/) }
  end

  context 'on AlmaLinux 10' do
    platform 'almalinux', '10'

    recipe do
      kafka_broker 'default' do
        broker('log.dirs' => ['/var/lib/kafka/data'])
      end
    end

    it { is_expected.to install_corretto_install('17').with(default: true) }
  end

  context 'when java management is disabled' do
    recipe do
      kafka_broker 'default' do
        manage_java false
        broker('log.dirs' => ['/var/lib/kafka/data'])
      end
    end

    it { is_expected.to_not install_openjdk_install('17') }
    it { is_expected.to_not install_corretto_install('17') }
  end

  context 'when a custom Java version is requested on Ubuntu' do
    recipe do
      kafka_broker 'default' do
        java_version '21'
        broker('log.dirs' => ['/var/lib/kafka/data'])
      end
    end

    it { is_expected.to install_openjdk_install('21').with(install_type: 'package', default: true) }
  end

  context 'when deleting a broker installation' do
    recipe do
      kafka_broker 'default' do
        broker('log.dirs' => ['/var/lib/kafka/data'])
        action :delete
      end
    end

    it { is_expected.to stop_systemd_unit('kafka.service') }
    it { is_expected.to disable_systemd_unit('kafka.service') }
    it { is_expected.to delete_systemd_unit('kafka.service') }
    it { is_expected.to delete_file('/etc/default/kafka') }
    it { is_expected.to delete_link('/opt/kafka') }
    it { is_expected.to delete_directory('/opt/kafka-3.9.1') }
    it { is_expected.to delete_directory('/var/log/kafka') }
    it { is_expected.to delete_directory('/var/lib/kafka/data') }
  end
end
