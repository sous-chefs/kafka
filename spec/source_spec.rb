# encoding: utf-8

require 'spec_helper'

describe 'kafka::source' do
  let :chef_run do
    ChefSpec::ChefRunner.new(platform: 'centos', version: '6.4').converge(described_recipe)
  end

  it 'includes kafka::default recipe' do
    expect(chef_run).to include_recipe('kafka::default')
  end

  it 'creates build directory' do
    expect(chef_run).to create_directory('/opt/kafka/build')

    directory = chef_run.directory('/opt/kafka/build')
    expect(directory).to be_owned_by('kafka', 'kafka')
    expect(directory.mode).to eq('755')
  end

  it 'downloads remote source of Kafka' do
    expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/kafka-0.8.0-beta1-src.tgz").with(
      source:   'https://dist.apache.org/repos/dist/release/kafka/kafka-0.8.0-beta1-src.tgz',
      checksum: 'e069a1d5e47d18944376b6ca30b625dc013045e7e1f948054ef3789a4b5f54b3',
      mode: '644'
    )
  end

  it 'compiles Kafka source' do
    expect(chef_run).to execute_bash_script('compile-kafka').with(
      cwd: '/opt/kafka/build'
    )
  end

  it 'installs compiled Kafka source' do
    expect(chef_run).to execute_bash_script('install-kafka').with(
      cwd: '/opt/kafka'
    )
  end
end
