# encoding: utf-8

require 'spec_helper'

describe 'kafka::default' do
  context 'when node[:kafka][:install_method] equals :source' do
    let :chef_run do
      ChefSpec::Runner.new(platform: 'centos', version: '6.4') do |node|
        node.set[:kafka][:install_method] = :source
      end.converge(described_recipe)
    end

    it 'includes kafka::source recipe' do
      expect(chef_run).to include_recipe('kafka::source')
    end
  end

  context 'when node[:kafka][:install_method] equals :binary' do
    let :chef_run do
      ChefSpec::Runner.new(platform: 'centos', version: '6.4').converge(described_recipe)
    end

    it 'includes kafka::binary recipe' do
      expect(chef_run).to include_recipe('kafka::binary')
    end
  end

  context 'when node[:kafka][:install_method] is something else' do
    let :chef_run do
      ChefSpec::Runner.new(platform: 'centos', version: '6.4') do |node|
        node.set[:kafka][:install_method] = :bork
      end
    end

    it 'terminates the chef run' do
      expect(Chef::Application).to receive(:fatal!).with(/Unknown install_method: bork/).once

      chef_run.converge(described_recipe)
    end
  end
end
