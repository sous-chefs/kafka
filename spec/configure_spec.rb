# encoding: utf-8

require 'spec_helper'

describe 'kafka::configure' do
  let :chef_run do
    ChefSpec::Runner.new(platform: 'centos', version: '6.4').converge(described_recipe)
  end

  it 'creates an init.d script' do
    expect(chef_run).to create_template('/etc/init.d/kafka')

    file = chef_run.template('/etc/init.d/kafka')
    expect(file.owner).to eq('root')
    expect(file.group).to eq('root')
    expect(file.mode).to eq('755')
  end

  it 'creates a kafka service' do
    service = chef_run.service('kafka')

    expect(service.action).to eq([:enable])
  end
end
