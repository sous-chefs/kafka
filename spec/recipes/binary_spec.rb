# encoding: utf-8

require 'spec_helper'

describe 'kafka::binary' do
  let :chef_run do
    ChefSpec::Runner.new(step_into: ['kafka_download']).converge(described_recipe)
  end

  let :kafka_download do
    chef_run.find_resource(:kafka_download, "#{Chef::Config[:file_cache_path]}/kafka_2.8.0-0.8.0.tar.gz")
  end

  it 'downloads remote binary release of Kafka' do
    expect(chef_run).to create_kafka_download("#{Chef::Config[:file_cache_path]}/kafka_2.8.0-0.8.0.tar.gz").with({
      source: 'https://dist.apache.org/repos/dist/release/kafka/0.8.0/kafka_2.8.0-0.8.0.tar.gz',
      checksum: 'ecadd6cf9f59e22444af5888c8b9595c5652ffab597db038418e85dfa834062e',
      md5_checksum: '593e0cf966e6b8cd1bbff5bff713c4b3',
      mode: '644'
    })
  end

  it 'extracts downloaded Kafka archive' do
    expect(kafka_download).to notify('execute[extract-kafka]').to(:run).immediately

    extract_kafka = chef_run.execute('extract-kafka')
    expect(extract_kafka.cwd).to eq('/opt/kafka/build')
    expect(extract_kafka.user).to eq('kafka')
    expect(extract_kafka.group).to eq('kafka')
  end

  it 'installs extracted Kafka archive' do
    expect(chef_run.execute('extract-kafka')).to notify('execute[install-kafka]').to(:run).immediately

    install_kafka = chef_run.execute('install-kafka')
    expect(install_kafka.cwd).to eq('/opt/kafka')
    expect(install_kafka.user).to eq('kafka')
    expect(install_kafka.group).to eq('kafka')
  end
end
