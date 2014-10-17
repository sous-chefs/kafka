# encoding: utf-8

require 'spec_helper'


describe 'kafka::_defaults' do
  let :chef_run do
    r = ChefSpec::Runner.new do |node|
      node.set.kafka.broker = attributes
    end
    r.converge(described_recipe)
  end

  let :node do
    chef_run.node
  end

  context 'broker id' do
    context 'when set using Property string notation' do
      let :attributes do
        {'broker.id' => 'set'}
      end

      it 'does not override it' do
        expect(node.kafka.broker['broker.id']).to eq('set')
      end

      it 'does not set it using other notations' do
        expect { node.kafka.broker.broker_id }.to raise_error(NoMethodError)
        expect { node.kafka.broker.id }.to raise_error(NoMethodError)
      end
    end

    context 'when set using nested hash notation' do
      let :attributes do
        {broker: {id: 'set'}}
      end

      it 'does not override it' do
        expect(node.kafka.broker.broker.id).to eq('set')
      end

      it 'does not set it using other notations' do
        expect(node.kafka.broker['broker.id']).to be_nil
        expect { node.kafka.broker.broker_id }.to raise_error(NoMethodError)
      end
    end

    context 'when set using underscore notation' do
      let :attributes do
        {broker_id: 'set'}
      end

      it 'does not override it' do
        expect(node.kafka.broker.broker_id).to eq('set')
      end

      it 'does not set it using other notations' do
        expect(node.kafka.broker['broker.id']).to be_nil
        expect { node.kafka.broker.broker.id }.to raise_error(NoMethodError)
      end
    end
  end

  context 'port' do
    let :attributes do
      {port: 9093}
    end

    it 'does not override it' do
      expect(node.kafka.broker.port).to eq(9093)
    end
  end

  context 'host name' do
    context 'when set using Property string notation' do
      let :attributes do
        {'host.name' => 'set'}
      end

      it 'does not override it' do
        expect(node.kafka.broker['host.name']).to eq('set')
      end

      it 'does not set it using other notations' do
        expect { node.kafka.broker.host_name }.to raise_error(NoMethodError)
        expect { node.kafka.broker.host.name }.to raise_error(NoMethodError)
      end
    end

    context 'when set using nested hash notation' do
      let :attributes do
        {host: {name: 'set'}}
      end

      it 'does not override it' do
        expect(node.kafka.broker.host.name).to eq('set')
      end

      it 'does not set it using other notations' do
        expect(node.kafka.broker['host.name']).to be_nil
        expect { node.kafka.broker.host_name }.to raise_error(NoMethodError)
      end
    end

    context 'when set using underscore notation' do
      let :attributes do
        {host_name: 'set'}
      end

      it 'does not override it' do
        expect(node.kafka.broker.host_name).to eq('set')
      end

      it 'does not set it using other notations' do
        expect(node.kafka.broker['host.name']).to be_nil
        expect { node.kafka.broker.host.name }.to raise_error(NoMethodError)
      end
    end
  end
end
