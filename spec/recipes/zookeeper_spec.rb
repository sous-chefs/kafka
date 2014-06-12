# encoding: utf-8

require 'spec_helper'

describe 'kafka::zookeeper' do

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
  end
   
  shared_examples_for 'a valid zookeeper setup' do
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

  context 'when node[:kafka][:install_method] equals :source' do
    it_behaves_like 'a valid install method' do
      let :install_method do
        :source
      end
    end
    it_behaves_like 'a valid zookeeper setup' do
      let :install_method do
        :source
      end
    end
  end

  context 'when node[:kafka][:install_method] equals :binary' do
    it_behaves_like 'a valid install method' do
      let :install_method do
        :binary
      end
    end
    it_behaves_like 'a valid zookeeper setup' do
      let :install_method do
        :source
      end
    end
  end

end
