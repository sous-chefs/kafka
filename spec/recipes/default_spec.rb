# encoding: utf-8

require 'spec_helper'

describe 'kafka::default' do
  let :chef_run do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'includes kafka::_defaults' do
    expect(chef_run).to include_recipe('kafka::_defaults')
  end

  it 'includes kafka::_setup' do
    expect(chef_run).to include_recipe('kafka::_setup')
  end

  it 'includes kafka::_install recipe' do
    expect(chef_run).to include_recipe('kafka::_install')
  end

  it 'includes kafka::_configure' do
    expect(chef_run).to include_recipe('kafka::_configure')
  end
end
