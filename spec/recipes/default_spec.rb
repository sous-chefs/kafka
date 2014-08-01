# encoding: utf-8

require 'spec_helper'

describe 'kafka::default' do
  TerminatedExecutionError = Class.new(StandardError)

  let :chef_run do
    ChefSpec::Runner.new do |node|
      node.set[:kafka][:install_method] = install_method
    end.converge(described_recipe)
  end

  shared_examples_for 'a valid install method' do
    it 'includes kafka::_setup' do
      expect(chef_run).to include_recipe('kafka::_setup')
    end

    it 'includes kafka::install_method recipe' do
      expect(chef_run).to include_recipe(%(kafka::#{install_method}))
    end

    it 'includes kafka::_configure' do
      expect(chef_run).to include_recipe('kafka::_configure')
    end
  end

  context 'when node.kafka.install_method equals :source' do
    it_behaves_like 'a valid install method' do
      let :install_method do
        :source
      end
    end
  end

  context 'when node.kafka.install_method equals \'source\'' do
    it_behaves_like 'a valid install method' do
      let :install_method do
        'source'
      end
    end
  end

  context 'when node.kafka.install_method equals :binary' do
    it_behaves_like 'a valid install method' do
      let :install_method do
        :binary
      end
    end
  end

  context 'when node.kafka.install_method equals \'binary\'' do
    it_behaves_like 'a valid install method' do
      let :install_method do
        'binary'
      end
    end
  end

  context 'when node.kafka.install_method is something else' do
    let :install_method do
      :bork
    end

    before do
      allow(Chef::Application).to receive(:fatal!).and_raise(TerminatedExecutionError)
    end

    it 'terminates the chef run' do
      expect { chef_run.converge(described_recipe) }.to raise_error(TerminatedExecutionError)
      expect(Chef::Application).to have_received(:fatal!).with(/Unknown install_method: :bork/).once
    end
  end
end
