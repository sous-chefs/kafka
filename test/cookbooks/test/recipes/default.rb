# frozen_string_literal: true

apt_update 'update' if platform_family?('debian')

java_package = value_for_platform_family(
  'debian' => 'default-jre-headless',
  'rhel' => 'java-17-openjdk-headless',
  'fedora' => 'java-17-openjdk-headless'
)

package java_package

kafka_broker 'default' do
  automatic_start true
  uid 1234
  gid 5678
  ulimit_file 128_000
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
