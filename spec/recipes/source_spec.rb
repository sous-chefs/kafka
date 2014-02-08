# encoding: utf-8

require 'spec_helper'

describe 'kafka::source' do
  let :chef_run do
    ChefSpec::Runner.new(step_into: ['kafka_download', 'kafka_install']).converge(described_recipe)
  end

  it 'downloads remote binary release of Kafka' do
    expect(chef_run).to create_kafka_download("#{Chef::Config[:file_cache_path]}/kafka-0.8.0-src.tgz").with({
      source: 'https://dist.apache.org/repos/dist/release/kafka/0.8.0/kafka-0.8.0-src.tgz',
      checksum: 'f4b7229671aba98dba9a882244cb597aab8a9018631575d28e119725a01cfc9a',
      md5_checksum: '46b3e65e38f1bde4b6251ea131d905f4',
      mode: '644'
    })
  end

  it 'compiles Kafka source' do
    expect(chef_run).to run_execute('compile-kafka').with_cwd('/opt/kafka/build')
  end

  it 'installs compiled Kafka source' do
    expect(chef_run).to run_kafka_install('/opt/kafka')
  end
end
