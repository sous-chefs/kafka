# encoding: utf-8

require 'spec_helper'

describe 'kafka::_configure' do
  let :chef_run do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  describe 'broker configuration file' do
    let :path do
      '/opt/kafka/config/server.properties'
    end

    context 'miscellaneous options' do
      it 'configures broker id from the node\'s ip address' do
        expect(chef_run).to have_configured(path).with('broker.id').as('10002')
      end

      it 'sets host.name to localhost' do
        expect(chef_run).to have_configured(path).with('#host.name').as('localhost')
      end

      it 'uses port from attribute' do
        expect(chef_run).to have_configured(path).with('port').as(9092)
      end

      it 'uses number of network threads from attribute' do
        expect(chef_run).to have_configured(path).with('num.network.threads').as(2)
      end

      it 'uses number of io threads from attribute' do
        expect(chef_run).to have_configured(path).with('num.io.threads').as(2)
      end
    end

    context 'socket related options' do
      it 'uses send buffer bytes from attribute' do
        expect(chef_run).to have_configured(path).with('socket.send.buffer.bytes').as(1048576)
      end

      it 'uses receive buffer bytes from attribute' do
        expect(chef_run).to have_configured(path).with('socket.receive.buffer.bytes').as(1048576)
      end

      it 'uses receive request max size from attribute' do
        expect(chef_run).to have_configured(path).with('socket.request.max.bytes').as(104857600)
      end
    end

    context 'log related options' do
      it 'uses log dirs from attribute' do
        expect(chef_run).to have_configured(path).with('log.dirs').as('/tmp/kafka-logs')
      end

      it 'uses default number of partitions from attribute' do
        expect(chef_run).to have_configured(path).with('num.partitions').as(1)
      end

      it 'uses log flush interval (messages) from attribute' do
        expect(chef_run).to have_configured(path).with('log.flush.interval.messages').as(10_000)
      end

      it 'uses log flush interval (ms) from attribute' do
        expect(chef_run).to have_configured(path).with('log.flush.interval.ms').as(1000)
      end

      it 'uses log retention hours from attribute' do
        expect(chef_run).to have_configured(path).with('log.retention.hours').as(168)
      end

      it 'uses log retention bytes from attribute' do
        expect(chef_run).to have_configured(path).with('log.retention.bytes').as(1073741824)
      end

      it 'uses log segment bytes from attribute' do
        expect(chef_run).to have_configured(path).with('log.segment.bytes').as(536870912)
      end

      it 'uses log cleanup interval (minutes) from attribute' do
        expect(chef_run).to have_configured(path).with('log.cleanup.interval.mins').as(1)
      end
    end

    context 'zookeeper related options' do
      it 'uses zookeeper connection (hosts) from attribute' do
        expect(chef_run).to have_configured(path).with('zookeeper.connect').as('')
      end

      it 'uses zookeeper connection timeout from attribute' do
        expect(chef_run).to have_configured(path).with('zookeeper.connection.timeout.ms').as(1_000_000)
      end
    end

    context 'metrics related options' do
      it 'uses metrics polling interval from attribute' do
        expect(chef_run).to have_configured(path).with('kafka.metrics.polling.interval.secs').as(5)
      end

      it 'uses metrics reporter(s) from attribute' do
        expect(chef_run).to have_configured(path).with('kafka.metrics.reporters').as('kafka.metrics.KafkaCSVMetricsReporter')
      end

      it 'uses csv metrics directory from attribute' do
        expect(chef_run).to have_configured(path).with('kafka.csv.metrics.dir').as('/tmp/kafka_metrics')
      end

      it 'uses csv metrics reporter_enabled from attribute' do
        expect(chef_run).to have_configured(path).with('kafka.csv.metrics.reporter.enabled').as(false)
      end
    end
  end

  context 'broker log4j configuration file' do
    let :path do
      '/opt/kafka/config/log4j.properties'
    end

    it 'configures log level' do
      expect(chef_run).to have_configured(path).with('log4j.rootLogger').as('INFO,R')
      expect(chef_run).to have_configured(path).with('log4j.logger.kafka').as('INFO')
    end

    it 'configures actual log path' do
      expect(chef_run).to have_configured(path).with('log4j.appender.R.File').as('/var/log/kafka/kafka.log')
    end

    it 'configures log level for ZkClient' do
      expect(chef_run).to have_configured(path).with('log4j.logger.org.IOItec.zkclient.ZkClient').as('INFO')
    end
  end

  context 'init.d script' do
    let :path do
      '/etc/init.d/kafka'
    end

    it 'creates one' do
      expect(chef_run).to create_template(path)

      file = chef_run.template(path)
      expect(file.owner).to eq('root')
      expect(file.group).to eq('root')
      expect(file.mode).to eq('755')
    end

    it 'sets KAFKA_HEAP_OPTS from attribute' do
      expect(chef_run).to have_configured(path).with('export KAFKA_HEAP_OPTS').as('"-Xmx1G -Xms1G"')
    end
  end

  it 'creates a \'kafka\' service' do
    service = chef_run.service('kafka')

    expect(service.action).to eq([:enable])
  end
end
