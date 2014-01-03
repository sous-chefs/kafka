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

    it 'creates the configuration file' do
      expect(chef_run).to create_template(path).with({
        owner: 'kafka',
        group: 'kafka',
        mode: '644'
      })
    end

    context 'general configuration' do
      it 'sets broker id from node\'s ip address' do
        expect(chef_run).to have_configured(path).with('broker.id').as('10002')
      end

      it 'sets default max byte size of messages' do
        expect(chef_run).to have_configured(path).with('message.max.bytes').as(1_000_000)
      end

      it 'sets default number of network threads' do
        expect(chef_run).to have_configured(path).with('num.network.threads').as(3)
      end

      it 'sets default number of io threads' do
        expect(chef_run).to have_configured(path).with('num.io.threads').as(8)
      end

      it 'sets default queued max requests' do
        expect(chef_run).to have_configured(path).with('queued.max.requests').as(500)
      end
    end

    context 'socket server configuration' do
      it 'sets default port' do
        expect(chef_run).to have_configured(path).with('port').as(6667)
      end

      it 'sets host name from node hostname attribute' do
        expect(chef_run).to have_configured(path).with('host.name').as('Fauxhai')
      end

      it 'sets default send buffer bytes' do
        expect(chef_run).to have_configured(path).with('socket.send.buffer.bytes').as(100 * 1024)
      end

      it 'sets default receive buffer bytes' do
        expect(chef_run).to have_configured(path).with('socket.receive.buffer.bytes').as(100 * 1024)
      end

      it 'sets default receive request max size' do
        expect(chef_run).to have_configured(path).with('socket.request.max.bytes').as(100 * 1024 * 1024)
      end
    end

    context 'log configuration' do
      shared_examples_for 'a hash based option' do
        let :attribute do
          option.to_s.gsub('_', '.')
        end

        context 'by default' do
          it 'configures a commented attribute' do
            expect(chef_run).to have_configured(path).with("#log.#{attribute}").as('')
          end
        end

        context 'with a hash of mappings' do
          let :mappings do
            {'topic1' => 12345, 'topic2' => 3000}
          end

          let :chef_run do
            ChefSpec::Runner.new do |node|
              node.set[:kafka][:log][option] = mappings
            end.converge(described_recipe)
          end

          it 'transforms it to a CSV string' do
            expect(chef_run).to have_configured(path).with("log.#{attribute}").as('topic1:12345,topic2:3000')
          end
        end
      end

      it 'sets default number of partitions' do
        expect(chef_run).to have_configured(path).with('num.partitions').as(1)
      end

      it 'sets default log dir(s)' do
        expect(chef_run).to have_configured(path).with('log.dirs').as('/tmp/kafka-logs')
      end

      it 'sets default log segment bytes' do
        expect(chef_run).to have_configured(path).with('log.segment.bytes').as(1 * 1024 * 1024 * 1024)
      end

      context 'segment bytes per topic' do
        it_behaves_like 'a hash based option' do
          let :option do
            :segment_bytes_per_topic
          end
        end
      end

      it 'sets default roll hours' do
        expect(chef_run).to have_configured(path).with('log.roll.hours').as(24 * 7)
      end

      context 'roll hours per topic' do
        it_behaves_like 'a hash based option' do
          let :option do
            :roll_hours_per_topic
          end
        end
      end

      it 'sets default log retention hours' do
        expect(chef_run).to have_configured(path).with('log.retention.hours').as(24 * 7)
      end

      context 'log retention hours per topic' do
        it_behaves_like 'a hash based option' do
          let :option do
            :retention_hours_per_topic
          end
        end
      end

      it 'sets default log retention bytes' do
        expect(chef_run).to have_configured(path).with('log.retention.bytes').as(-1)
      end

      context 'log retention bytes per topic' do
        it_behaves_like 'a hash based option' do
          let :option do
            :retention_bytes_per_topic
          end
        end
      end

      it 'sets default log cleanup interval (minutes)' do
        expect(chef_run).to have_configured(path).with('log.cleanup.interval.mins').as(10)
      end

      it 'sets default max bytesize of index' do
        expect(chef_run).to have_configured(path).with('log.index.size.max.bytes').as(10 * 1024 * 1024)
      end

      it 'sets default index interval bytes' do
        expect(chef_run).to have_configured(path).with('log.index.interval.bytes').as(4096)
      end

      it 'sets default log flush interval (messages)' do
        expect(chef_run).to have_configured(path).with('log.flush.interval.messages').as(10_000)
      end

      it 'sets default log flush interval (ms)' do
        expect(chef_run).to have_configured(path).with('log.flush.interval.ms').as(3000)
      end

      context 'log flush interval (ms) per topic' do
        it_behaves_like 'a hash based option' do
          let :option do
            :flush_interval_ms_per_topic
          end
        end
      end

      it 'sets default log flush scheduler interval (ms)' do
        expect(chef_run).to have_configured(path).with('log.flush.scheduler.interval.ms').as(3000)
      end

      it 'automatically creates topics' do
        expect(chef_run).to have_configured(path).with('auto.create.topics.enable').as(true)
      end
    end

    context 'replication configuration' do
      it 'sets default controller socket timeout' do
        expect(chef_run).to have_configured(path).with('controller.socket.timeout.ms').as(30_000)
      end

      it 'sets default controller message queue size' do
        expect(chef_run).to have_configured(path).with('controller.message.queue.size').as(10)
      end

      it 'sets default replication factor' do
        expect(chef_run).to have_configured(path).with('default.replication.factor').as(1)
      end

      it 'sets default replica lag time max (ms)' do
        expect(chef_run).to have_configured(path).with('replica.lag.time.max.ms').as(10_000)
      end

      it 'sets default replica message lag max' do
        expect(chef_run).to have_configured(path).with('replica.lag.max.messages').as(4000)
      end

      it 'sets default replica socket timeout' do
        expect(chef_run).to have_configured(path).with('replica.socket.timeout.ms').as(30 * 1000)
      end

      it 'sets default replica socket receive buffer bytes' do
        expect(chef_run).to have_configured(path).with('replica.socket.receive.buffer.bytes').as(64 * 1024)
      end

      it 'sets default replica fetch max bytes' do
        expect(chef_run).to have_configured(path).with('replica.fetch.max.bytes').as(1024 * 1024)
      end

      it 'sets default replica fetch min bytes' do
        expect(chef_run).to have_configured(path).with('replica.fetch.min.bytes').as(1)
      end

      it 'sets default replica fetch max wait (ms)' do
        expect(chef_run).to have_configured(path).with('replica.fetch.wait.max.ms').as(500)
      end

      it 'sets default replica fetchers' do
        expect(chef_run).to have_configured(path).with('num.replica.fetchers').as(1)
      end

      it 'sets default replica high watermark checkpoint interval (ms)' do
        expect(chef_run).to have_configured(path).with('replica.high.watermark.checkpoint.interval.ms').as(5000)
      end

      it 'sets default fetch purgatory purge interval' do
        expect(chef_run).to have_configured(path).with('fetch.purgatory.purge.interval.requests').as(10_000)
      end

      it 'sets default producer purgatory purge interval' do
        expect(chef_run).to have_configured(path).with('producer.purgatory.purge.interval.requests').as(10_000)
      end
    end

    context 'controlled shutdown configuration' do
      it 'sets default max retries' do
        expect(chef_run).to have_configured(path).with('controlled.shutdown.max.retries').as(3)
      end

      it 'sets default retry backoff (ms)' do
        expect(chef_run).to have_configured(path).with('controlled.shutdown.retry.backoff.ms').as(5000)
      end

      it 'sets default value for enable' do
        expect(chef_run).to have_configured(path).with('controlled.shutdown.enable').as(false)
      end
    end

    context 'zookeeper configuration' do
      it 'sets zookeeper hosts' do
        expect(chef_run).to have_configured(path).with('zookeeper.connect').as('')
      end

      it 'sets default zookeeper connection timeout' do
        expect(chef_run).to have_configured(path).with('zookeeper.connection.timeout.ms').as(6000)
      end

      it 'sets default zookeeper session timeout' do
        expect(chef_run).to have_configured(path).with('zookeeper.session.timeout.ms').as(6000)
      end

      it 'sets default zookeeper sync time (ms)' do
        expect(chef_run).to have_configured(path).with('zookeeper.sync.time.ms').as(2000)
      end
    end
  end

  context 'broker log4j configuration file' do
    let :path do
      '/opt/kafka/config/log4j.properties'
    end

    it 'creates the configuration file' do
      expect(chef_run).to create_template(path).with({
        owner: 'kafka',
        group: 'kafka',
        mode: '644'
      })
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

  shared_examples_for 'an init style' do
    let :chef_run do
      ChefSpec::Runner.new do |node|
        node.set[:kafka][:scala_version] = '2.8.0'
        node.set[:kafka][:init_style] = init_style
      end.converge(described_recipe)
    end

    let :script_permissions do
      '755'
    end

    it 'creates a script at the appropriate location' do
      expect(chef_run).to create_template(init_path).with({
        owner: 'root',
        group: 'root',
        mode: script_permissions
      })
    end

    context 'environment variables' do
      it 'creates a file for setting necessary environment variables' do
        expect(chef_run).to create_template(env_path).with({
          owner: 'root',
          group: 'root',
          mode: '644'
        })
      end

      it 'sets SCALA_VERSION' do
        expect(chef_run).to have_configured(env_path).with('export SCALA_VERSION').as('"2.8.0"')
      end

      it 'sets JMX_PORT' do
        expect(chef_run).to have_configured(env_path).with('export JMX_PORT').as('"9999"')
      end

      it 'sets KAFKA_LOG4J_OPTS' do
        expect(chef_run).to have_configured(env_path).with('export KAFKA_LOG4J_OPTS').as('"-Dlog4j.configuration=file:/opt/kafka/config/log4j.properties"')
      end

      it 'sets KAFKA_HEAP_OPTS' do
        expect(chef_run).to have_configured(env_path).with('export KAFKA_HEAP_OPTS').as('"-Xmx1G -Xms1G"')
      end

      it 'sets KAFKA_OPTS' do
        expect(chef_run).to have_configured(env_path).with('export KAFKA_OPTS').as('""')
      end

      it 'sets KAFKA_GC_LOG_OPTS' do
        expect(chef_run).to have_configured(env_path).with('export KAFKA_GC_LOG_OPTS').as('"-Xloggc:/var/log/kafka/kafka-gc.log -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps"')
      end

      it 'sets KAFKA_RUN' do
        expect(chef_run).to have_configured(env_path).with('KAFKA_RUN').as('"/opt/kafka/bin/kafka-run-class.sh"')
      end

      it 'sets KAFKA_ARGS' do
        expect(chef_run).to have_configured(env_path).with('KAFKA_ARGS').as('"kafka.Kafka"')
      end

      it 'sets KAFKA_CONFIG' do
        expect(chef_run).to have_configured(env_path).with('KAFKA_CONFIG').as('"/opt/kafka/config/server.properties"')
      end
    end
  end

  context 'init script(s)' do
    context 'when init_style is :sysv' do
      it_behaves_like 'an init style' do
        let :init_style do
          'sysv'
        end

        let :init_path do
          '/etc/init.d/kafka'
        end

        let :env_path do
          '/etc/sysconfig/kafka'
        end
      end
    end

    context 'when init_style is :upstart' do
      it_behaves_like 'an init style' do
        let :init_style do
          'upstart'
        end

        let :init_path do
          '/etc/init/kafka.conf'
        end

        let :env_path do
          '/etc/default/kafka'
        end

        let :script_permissions do
          '644'
        end
      end
    end
  end

  it 'enables a \'kafka\' service' do
    expect(chef_run).to enable_service('kafka')
  end
end
