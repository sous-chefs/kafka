# encoding: utf-8

require 'spec_helper'


describe 'kafka::_defaults' do
  let :chef_run do
    r = ChefSpec::SoloRunner.new do |node|
      node.set['kafka']['broker'] = broker_attributes
    end
    r.converge(described_recipe)
  end

  let :node do
    chef_run.node
  end

  context 'broker id' do
    context 'when set using Property string notation' do
      let :broker_attributes do
        {'broker.id' => 'set'}
      end

      it 'does not override it' do
        expect(node['kafka']['broker']['broker.id']).to eq('set')
      end

      it 'does not set it using other notations' do
        expect(node['kafka']['broker']['broker_id']).to be_nil
        expect { node['kafka']['broker']['broker']['id'] }.to raise_error(NoMethodError)
      end
    end

    context 'when set using nested hash notation' do
      let :broker_attributes do
        {'broker' => {'id' => 'set'}}
      end

      it 'does not override it' do
        expect(node['kafka']['broker']['broker']['id']).to eq('set')
      end

      it 'does not set it using other notations' do
        expect(node['kafka']['broker']['broker.id']).to be_nil
        expect(node['kafka']['broker']['broker_id']).to be_nil
      end
    end

    context 'when set using underscore notation' do
      let :broker_attributes do
        {'broker_id' => 'set'}
      end

      it 'does not override it' do
        expect(node['kafka']['broker']['broker_id']).to eq('set')
      end

      it 'does not set it using other notations' do
        expect(node['kafka']['broker']['broker.id']).to be_nil
        expect { node['kafka']['broker']['broker']['id'] }.to raise_error(NoMethodError)
      end
    end

    context 'when set to `nil`' do
      let :broker_attributes do
        {'broker' => {'id' => nil}}
      end

      it 'does not override it' do
        expect(node['kafka']['broker']['broker']['id']).to be_nil
      end
    end

    context 'when not set' do
      let :broker_attributes do
        {}
      end

      it 'does override it' do
        expect(node['kafka']['broker']['broker_id']).to_not be_nil
      end
    end
  end

  context 'port' do
    context 'when set' do
      let :broker_attributes do
        {'port' => 9093}
      end

      it 'does not override it' do
        expect(node['kafka']['broker']['port']).to eq(9093)
      end
    end

    context 'when set to `nil`' do
      let :broker_attributes do
        {'port' => nil}
      end

      it 'does not override it' do
        expect(node['kafka']['broker']['port']).to be_nil
      end
    end

    context 'when not set' do
      let :broker_attributes do
        {}
      end

      it 'does override it' do
        expect(node['kafka']['broker']['port']).to eq(6667)
      end
    end
  end
end
