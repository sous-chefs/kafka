# encoding: utf-8

require 'spec_helper'

describe 'kafka::binary' do
  let :chef_run do
    ChefSpec::Runner.new(platform: 'centos', version: '6.4').converge(described_recipe)
  end

  let :remote_file do
    chef_run.remote_file("#{Chef::Config[:file_cache_path]}/kafka_2.8.0-0.8.0-beta1.tgz")
  end

  let :validate_block do
    chef_run.ruby_block('validate-tarball')
  end

  it 'includes kafka::configure recipe' do
    expect(chef_run).to include_recipe('kafka::configure')
  end

  it 'creates \'dist\' directory' do
    expect(chef_run).to create_directory('/opt/kafka/dist')

    directory = chef_run.directory('/opt/kafka/dist')
    expect(directory.owner).to eq('kafka')
    expect(directory.group).to eq('kafka')
    expect(directory.mode).to eq('755')
  end

  it 'downloads remote binary release of Kafka' do
    expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/kafka_2.8.0-0.8.0-beta1.tgz").with(
      source:   'https://dist.apache.org/repos/dist/release/kafka/kafka_2.8.0-0.8.0-beta1.tgz',
      checksum: '750046ab729d2dbc1d5756794ebf8fcb640879b23a64749164c43063286316b8',
      mode: '644'
    )
  end

  it 'validates downloaded Kafka archive' do
    expect(remote_file).to notify('ruby_block[validate-tarball]').to(:create).immediately
  end

  it 'extracts downloaded Kafka archive' do
    expect(validate_block).to notify('execute[extract-kafka]').to(:run).immediately

    extract_kafka = chef_run.execute('extract-kafka')
    expect(extract_kafka.cwd).to eq('/opt/kafka/dist')
    expect(extract_kafka.user).to be_nil
    expect(extract_kafka.group).to be_nil
  end

  it 'installs extracted Kafka archive' do
    expect(chef_run.execute('extract-kafka')).to notify('execute[install-kafka]').to(:run).immediately

    install_kafka = chef_run.execute('install-kafka')
    expect(install_kafka.cwd).to eq('/opt/kafka')
    expect(install_kafka.user).to eq('kafka')
    expect(install_kafka.group).to eq('kafka')
  end
end
