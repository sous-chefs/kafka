# encoding: utf-8

require 'spec_helper'

describe 'kafka::binary' do
  let :chef_run do
    ChefSpec::Runner.new(step_into: %w(kafka_download kafka_install)) do |node|
      node.set[:kafka][:install_method] = :binary
    end.converge(described_recipe)
  end

  it 'downloads remote binary release of Kafka' do
    expect(chef_run).to create_kafka_download(%(#{Chef::Config[:file_cache_path]}/kafka_2.9.2-0.8.1.1.tgz))
    expect(chef_run).to create_remote_file(%(#{Chef::Config[:file_cache_path]}/kafka_2.9.2-0.8.1.1.tgz))
  end

  it 'validates download' do
    expect(chef_run).not_to run_ruby_block('kafka-validate-download')

    remote_file = chef_run.remote_file(%(#{Chef::Config[:file_cache_path]}/kafka_2.9.2-0.8.1.1.tgz))
    expect(remote_file).to notify('ruby_block[kafka-validate-download]').immediately
  end

  it 'extracts downloaded Kafka archive' do
    expect(chef_run).to run_execute('extract-kafka').with({
      cwd: '/opt/kafka/build',
      user: 'root',
      group: 'root'
    })
  end

  it 'installs extracted Kafka archive' do
    expect(chef_run).to run_kafka_install('/opt/kafka')
    expect(chef_run).to run_execute('install-kafka')
    expect(chef_run).to run_execute('remove-kafka-build')
  end

  context 'archive extension for different versions' do
    let :chef_run do
      ChefSpec::Runner.new do |node|
        node.set[:kafka][:version] = kafka_version
        node.set[:kafka][:install_method] = :binary
      end.converge(described_recipe)
    end

    context 'when version is 0.8.0' do
      let :kafka_version do
        '0.8.0'
      end

      it 'uses .tar.gz' do
        expect(chef_run).to create_kafka_download(%(#{Chef::Config[:file_cache_path]}/kafka_2.9.2-0.8.0.tar.gz))
      end
    end

    context 'when version is 0.8.1' do
      let :kafka_version do
        '0.8.1'
      end

      it 'uses .tgz' do
        expect(chef_run).to create_kafka_download(%(#{Chef::Config[:file_cache_path]}/kafka_2.9.2-0.8.1.tgz))
      end
    end

    context 'when version is 0.8.1.1' do
      let :kafka_version do
        '0.8.1.1'
      end

      it 'uses .tgz' do
        expect(chef_run).to create_kafka_download(%(#{Chef::Config[:file_cache_path]}/kafka_2.9.2-0.8.1.1.tgz))
      end
    end
  end
end
