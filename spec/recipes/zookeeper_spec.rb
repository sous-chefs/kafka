# encoding: utf-8

require 'spec_helper'

describe 'kafka::zookeeper' do
  let :chef_run do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'includes kafka::default' do
    expect(chef_run).to include_recipe('kafka::default')
  end

  it 'creates a configuration file for Zookeeper' do
    expect(chef_run).to create_template('/opt/kafka/config/zookeeper.properties').with({
      owner: 'kafka',
      group: 'kafka',
      mode: '644'
    })
  end

  it 'creates a directory for Zookeeper logs' do
    expect(chef_run).to create_directory('/var/log/zookeeper').with({
      owner: 'kafka',
      group: 'kafka',
      mode: '755',
      recursive: true
    })
  end

  it 'creates a configuration file for Zookeeper log4j' do
    expect(chef_run).to create_template('/opt/kafka/config/zookeeper.log4j.properties').with({
      owner: 'kafka',
      group: 'kafka',
      mode: '644',
      variables: {process: 'zookeeper', log_dir: '/var/log/zookeeper'}
    })
  end

  it 'creates a sysconfig file' do
    expect(chef_run).to create_template('/etc/sysconfig/zookeeper').with({
      owner: 'root',
      group: 'root',
      mode: '644'
    })
  end

  it 'creates an init.d script for Zookeeper' do
    expect(chef_run).to create_template('/etc/init.d/zookeeper').with({
      owner: 'root',
      group: 'root',
      mode: '755'
    })
  end

  it 'enables a \'zookeeper\' service' do
    expect(chef_run).to enable_service('zookeeper')
  end

  it 'starts a \'zookeeper\' service' do
    expect(chef_run).to start_service('zookeeper')
  end
end
