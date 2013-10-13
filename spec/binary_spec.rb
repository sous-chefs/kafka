# encoding: utf-8

require 'spec_helper'

describe 'kafka::binary' do
  let :chef_run do
    ChefSpec::ChefRunner.new(platform: 'centos', version: '6.4').converge(described_recipe)
  end

  it 'includes kafka::default recipe' do
    expect(chef_run).to include_recipe('kafka::default')
  end

  it 'creates dist directory' do
    expect(chef_run).to create_directory('/opt/kafka/dist')

    directory = chef_run.directory('/opt/kafka/dist')
    expect(directory).to be_owned_by('kafka', 'kafka')
    expect(directory.mode).to eq('755')
  end

  it 'downloads remote binary release of Kafka' do
    expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/kafka_2.8.0-0.8.0-beta1.tgz").with(
      source:   'https://dist.apache.org/repos/dist/release/kafka/kafka_2.8.0-0.8.0-beta1.tgz',
      checksum: '750046ab729d2dbc1d5756794ebf8fcb640879b23a64749164c43063286316b8',
      mode: '644'
    )
  end

  it 'extracts downloaded Kafka archive' do
    expect(chef_run).to execute_bash_script('extract-kafka').with(
      cwd: '/opt/kafka/dist'
    )
  end

  it 'installs extracted Kafka archive' do
    expect(chef_run).to execute_bash_script('install-kafka').with(
      cwd: '/opt/kafka'
    )
  end
end
