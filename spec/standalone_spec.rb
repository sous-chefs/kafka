# encoding: utf-8

require 'spec_helper'

describe 'kafka::standalone' do
  let :chef_run do
    ChefSpec::Runner.new(platform: 'centos', version: '6.4').converge(described_recipe)
  end

  it 'includes kafka::binary' do
    expect(chef_run).to include_recipe('kafka::binary')
  end

  it 'creates a configuration file for Zookeeper' do
    expect(chef_run).to create_template('/opt/kafka/config/zookeeper.properties').with(
      owner: 'kafka',
      group: 'kafka',
      mode: '644'
    )
  end

  it 'creates a directory for Zookeeper logs' do
    expect(chef_run).to create_directory('/var/log/zookeeper').with(
      owner: 'kafka',
      group: 'kafka',
      mode: '755',
      recursive: true
    )
  end

  it 'creates a configuration file for Zookeeper log4j' do
    expect(chef_run).to create_template('/opt/kafka/config/zookeeper.log4j.properties').with(
      owner: 'kafka',
      group: 'kafka',
      mode: '644',
      variables: {process: 'zookeeper', log_dir: '/var/log/zookeeper'}
    )
  end

  it 'creates an init.d script for Zookeeper' do
    expect(chef_run).to create_template('/etc/init.d/zookeeper')

    file = chef_run.template('/etc/init.d/zookeeper')
    expect(file.owner).to eq('root')
    expect(file.group).to eq('root')
    expect(file.mode).to eq('755')
  end

  it 'creates a \'zookeeper\' service' do
    service = chef_run.service('zookeeper')

    expect(service.action).to eq([:enable, :start])
  end

  it 'starts kafka' do
    service = chef_run.service('kafka')

    expect(service.action).to eq([:enable, :start])
  end
end
