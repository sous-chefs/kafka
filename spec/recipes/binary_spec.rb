# encoding: utf-8

require 'spec_helper'

describe 'kafka::binary' do
  let :chef_run do
    ChefSpec::Runner.new(step_into: ['kafka_download', 'kafka_install']).converge(described_recipe)
  end

  it 'downloads remote binary release of Kafka' do
    expect(chef_run).to create_kafka_download("#{Chef::Config[:file_cache_path]}/kafka_2.8.0-0.8.0.tar.gz").with({
      source: 'https://dist.apache.org/repos/dist/release/kafka/0.8.0/kafka_2.8.0-0.8.0.tar.gz',
      checksum: 'ecadd6cf9f59e22444af5888c8b9595c5652ffab597db038418e85dfa834062e',
      md5_checksum: '593e0cf966e6b8cd1bbff5bff713c4b3',
      mode: '644'
    })

    expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/kafka_2.8.0-0.8.0.tar.gz").with({
      source: 'https://dist.apache.org/repos/dist/release/kafka/0.8.0/kafka_2.8.0-0.8.0.tar.gz',
      checksum: 'ecadd6cf9f59e22444af5888c8b9595c5652ffab597db038418e85dfa834062e',
      mode: '644'
    })
  end

  it 'validates download' do
    # Keep this around to achieve 100% coverage until the next version of ChefSpec
    # is released. See https://github.com/sethvargo/chefspec/issues/379
    expect(chef_run).not_to run_ruby_block('validate-download')

    remote_file = chef_run.remote_file("#{Chef::Config[:file_cache_path]}/kafka_2.8.0-0.8.0.tar.gz")
    expect(remote_file).to notify('ruby_block[validate-download]').immediately
  end

  it 'extracts downloaded Kafka archive' do
    expect(chef_run).to run_execute('extract-kafka').with({
      cwd: '/opt/kafka/build',
      user: 'kafka',
      group: 'kafka'
    })
  end

  it 'installs extracted Kafka archive' do
    expect(chef_run).to run_kafka_install('/opt/kafka')

    expect(chef_run).to run_execute('install-kafka')
  end
end
