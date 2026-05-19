# frozen_string_literal: true

case node['platform_family']
when 'debian'
  apt_update 'update apt cache'

  java_package = if platform?('debian') && node['platform_version'].to_i >= 13
                   'openjdk-21-jre-headless'
                 else
                   'openjdk-17-jre-headless'
                 end
  package java_package
when 'rhel'
  java_package = if node['platform_version'].to_i >= 10
                   'java-21-openjdk-headless'
                 else
                   'java-17-openjdk-headless'
                 end
  package java_package
when 'fedora'
  package 'java-21-openjdk-headless'
when 'amazon'
  package 'java-17-openjdk-headless'
end

kafka_broker 'default' do
  version node['kafka_test']['version']
  scala_version node['kafka_test']['scala_version']
  sha512_checksum node['kafka_test']['sha512_checksum']
  uid 1234
  gid 5678
  heap_opts '-Xmx256M -Xms256M'
  ulimit_file 128000
  automatic_start true
  format_storage true
  cluster_id 'MkU3OEVBNTcwNTJENDM2Qk'
  broker_config(
    'process.roles' => 'broker,controller',
    'node.id' => 1,
    'controller.quorum.voters' => '1@localhost:9093',
    'listeners' => 'PLAINTEXT://:9092,CONTROLLER://:9093',
    'advertised.listeners' => 'PLAINTEXT://localhost:9092',
    'controller.listener.names' => 'CONTROLLER',
    'listener.security.protocol.map' => 'CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT',
    'inter.broker.listener.name' => 'PLAINTEXT',
    'log.dirs' => '/var/lib/kafka/data',
    'offsets.topic.replication.factor' => 1,
    'transaction.state.log.replication.factor' => 1,
    'transaction.state.log.min.isr' => 1
  )
end
