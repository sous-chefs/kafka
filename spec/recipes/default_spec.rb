# encoding: utf-8

require 'spec_helper'

describe 'kafka::default' do
  let :chef_run do
    ChefSpec::Runner.new do |node|
      node.set[:kafka][:install_method] = install_method
    end
  end

  context 'when node[:kafka][:install_method] equals :source' do
    let :install_method do
      :source
    end

    it 'includes kafka::source recipe' do
      chef_run.converge(described_recipe)

      expect(chef_run).to include_recipe('kafka::source')
    end
  end

  context 'when node[:kafka][:install_method] equals :binary' do
    let :install_method do
      :binary
    end

    it 'includes kafka::binary recipe' do
      chef_run.converge(described_recipe)

      expect(chef_run).to include_recipe('kafka::binary')
    end
  end

  context 'when node[:kafka][:install_method] is something else' do
    let :install_method do
      :bork
    end

    it 'terminates the chef run' do
      expect(Chef::Application).to receive(:fatal!).with(/Unknown install_method: bork/).once

      chef_run.converge(described_recipe)
    end
  end
end
