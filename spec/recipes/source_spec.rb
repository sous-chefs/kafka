# encoding: utf-8

require 'spec_helper'

describe 'kafka::source' do
  let :chef_run do
    ChefSpec::Runner.new(step_into: %w(kafka_download kafka_install)) do |node|
      node.set[:kafka][:install_method] = :source
    end.converge(described_recipe)
  end

  it 'downloads remote source release of Kafka' do
    expect(chef_run).to create_kafka_download(%(#{Chef::Config[:file_cache_path]}/kafka-0.8.1-src.tgz)).with({
      source: 'https://archive.apache.org/dist/kafka/0.8.1/kafka-0.8.1-src.tgz',
      checksum: 'a05d0f95a5e42a7260769649efbc75e6938a0dc55decb4d32e601476414ac826',
      md5_checksum: '7174f7855cb2f7e131799cb23805cd35',
      mode: '644'
    })

    expect(chef_run).to create_remote_file(%(#{Chef::Config[:file_cache_path]}/kafka-0.8.1-src.tgz)).with({
      source: 'https://archive.apache.org/dist/kafka/0.8.1/kafka-0.8.1-src.tgz',
      checksum: 'a05d0f95a5e42a7260769649efbc75e6938a0dc55decb4d32e601476414ac826',
      mode: '644'
    })
  end

  it 'validates download' do
    expect(chef_run).not_to run_ruby_block('kafka-validate-download')

    remote_file = chef_run.remote_file(%(#{Chef::Config[:file_cache_path]}/kafka-0.8.1-src.tgz))
    expect(remote_file).to notify('ruby_block[kafka-validate-download]').immediately
  end

  context 'compilation of Kafka source' do
    let :chef_run do
      ChefSpec::Runner.new do |node|
        node.set[:kafka][:install_method] = :source
        node.set[:kafka][:version] = kafka_version
      end.converge(described_recipe)
    end

    let :compile_command do
      chef_run.execute('compile-kafka').command
    end

    context 'when version is 0.8.0' do
      let :kafka_version do
        '0.8.0'
      end

      it 'downloads kafka' do
        expect(chef_run).to create_kafka_download(%(#{Chef::Config[:file_cache_path]}/kafka-0.8.0-src.tgz))
      end

      it 'runs execute block' do
        expect(chef_run).to run_execute('compile-kafka').with_cwd('/opt/kafka/build')
      end

      it 'uses sbt' do
        expect(compile_command).to include './sbt update'
        expect(compile_command).to match /\.\/sbt .+ release-zip/
      end
    end

    context 'when version is 0.8.1' do
      let :kafka_version do
        '0.8.1'
      end

      it 'runs execute block' do
        expect(chef_run).to run_execute('compile-kafka').with_cwd('/opt/kafka/build')
      end

      it 'uses gradle' do
        expect(compile_command).to match /\.\/gradlew .+ releaseTarGz -x signArchives/
      end
    end
  end

  it 'installs compiled Kafka source' do
    expect(chef_run).to run_kafka_install('/opt/kafka')
    expect(chef_run).to run_execute('install-kafka')
    expect(chef_run).to run_execute('remove-kafka-build')
  end
end
