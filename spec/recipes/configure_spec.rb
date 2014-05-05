# encoding: utf-8

require 'spec_helper'

describe 'kafka::_configure' do
  let :chef_run do
    ChefSpec::Runner.new do |node|
      node.set[:kafka] = kafka_attributes
      node.set[:kafka][:version] = kafka_version
    end.converge(described_recipe)
  end

  let :kafka_version do
    '0.8.1'
  end

  let :kafka_attributes do
    {}
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

    context 'default configuration' do
      context 'general configuration' do
        it 'sets broker id from node\'s ip address' do
          expect(chef_run).to have_configured(path).with('broker.id').as('10002')
        end

        context 'when broker id is larger than 2**31' do
          let :chef_run do
            ChefSpec::Runner.new do |node|
              node.automatic[:ipaddress] = '255.255.255.255'
            end.converge(described_recipe)
          end

          it 'mod\'s it by 2**31' do
            expect(chef_run).to have_configured(path).with('broker.id').as('1852184791')
          end
        end

        it 'does not set message.max.bytes' do
          expect(chef_run).not_to have_configured(path).with('message.max.bytes')
        end

        it 'does not set number of network threads' do
          expect(chef_run).not_to have_configured(path).with('num.network.threads')
        end

        it 'does not set number of io threads' do
          expect(chef_run).not_to have_configured(path).with('num.io.threads')
        end

        it 'does not set number of background threads' do
          expect(chef_run).not_to have_configured(path).with('background.threads')
        end

        it 'does not set queued max requests' do
          expect(chef_run).not_to have_configured(path).with('queued.max.requests')
        end
      end

      context 'socket server configuration' do
        it 'sets port' do
          expect(chef_run).to have_configured(path).with('port').as(6667)
        end

        it 'does not set host name from node hostname attribute' do
          expect(chef_run).to have_configured(path).with('host.name').as('Fauxhai')
        end

        it 'does not set advertised host.name attribute' do
          expect(chef_run).not_to have_configured(path).with('advertised.host.name').as('Fauxhai')
        end

        it 'does not set advertised port attribute' do
          expect(chef_run).not_to have_configured(path).with('advertised.port')
        end

        it 'does not set send buffer bytes' do
          expect(chef_run).not_to have_configured(path).with('socket.send.buffer.bytes')
        end

        it 'does not set receive buffer bytes' do
          expect(chef_run).not_to have_configured(path).with('socket.receive.buffer.bytes')
        end

        it 'does not set receive request max size' do
          expect(chef_run).not_to have_configured(path).with('socket.request.max.bytes')
        end
      end

      context 'log configuration' do
        it 'does not set number of partitions' do
          expect(chef_run).not_to have_configured(path).with('num.partitions')
        end

        it 'does not set log dir(s)' do
          expect(chef_run).not_to have_configured(path).with('log.dirs')
        end

        it 'does not set log segment bytes' do
          expect(chef_run).not_to have_configured(path).with('log.segment.bytes')
        end

        it 'does not set segment bytes per topic' do
          expect(chef_run).not_to have_configured(path).with('log.segment.bytes.per.topic')
        end

        it 'does not set roll hours' do
          expect(chef_run).not_to have_configured(path).with('log.roll.hours')
        end

        it 'does not set roll hours per topic' do
          expect(chef_run).not_to have_configured(path).with('log.roll.hours.per.topic')
        end

        it 'does not set log retention hours' do
          expect(chef_run).not_to have_configured(path).with('log.retention.hours')
        end

        it 'does not set retention hours per topic' do
          expect(chef_run).not_to have_configured(path).with('log.retention.hours.per.topic')
        end

        it 'does not set log retention bytes' do
          expect(chef_run).not_to have_configured(path).with('log.retention.bytes')
        end

        it 'does not set retention bytes per topic' do
          expect(chef_run).not_to have_configured(path).with('log.retention.bytes.per.topic')
        end

        it 'does not set log cleanup interval (minutes)' do
          expect(chef_run).not_to have_configured(path).with('log.cleanup.interval.mins')
        end

        it 'does not set log retention check interval (milliseconds)' do
          expect(chef_run).not_to have_configured(path).with('log.retention.check.interval.ms')
        end

        it 'does not set delete delay ms' do
          expect(chef_run).not_to have_configured(path).with('log.delete.delay.ms')
        end

        it 'does not set flush offset checkpoint interval' do
          expect(chef_run).not_to have_configured(path).with('log.flush.offset.checkpoint.interval.ms')
        end

        it 'does not set max bytesize of index' do
          expect(chef_run).not_to have_configured(path).with('log.index.size.max.bytes')
        end

        it 'does not set index interval bytes' do
          expect(chef_run).not_to have_configured(path).with('log.index.interval.bytes')
        end

        it 'does not set log flush interval (messages)' do
          expect(chef_run).not_to have_configured(path).with('log.flush.interval.messages')
        end

        it 'does not set log flush interval (ms)' do
          expect(chef_run).not_to have_configured(path).with('log.flush.interval.ms')
        end

        it 'does not set flush interval (ms) per topic' do
          expect(chef_run).not_to have_configured(path).with('log.flush.interval.ms.per.topic')
        end

        it 'does not set log flush scheduler interval (ms)' do
          expect(chef_run).not_to have_configured(path).with('log.flush.scheduler.interval.ms')
        end

        it 'does not set auto create topics enable' do
          expect(chef_run).not_to have_configured(path).with('auto.create.topics.enable')
        end

        it 'does not set cleanup policy' do
          expect(chef_run).not_to have_configured(path).with('log.cleanup.policy')
        end
      end

      context 'log cleaner configuration' do
        it 'does not set cleaner enable' do
          expect(chef_run).not_to have_configured(path).with('log.cleaner.enable')
        end

        it 'does not set cleaner threads' do
          expect(chef_run).not_to have_configured(path).with('log.cleaner.threads')
        end

        it 'does not set cleaner io max bytes per second' do
          expect(chef_run).not_to have_configured(path).with('log.cleaner.io.max.bytes.per.second')
        end

        it 'does not set cleaner dedupe buffer size' do
          expect(chef_run).not_to have_configured(path).with('log.cleaner.dedupe.buffer.size')
        end

        it 'does not set cleaner io buffer size' do
          expect(chef_run).not_to have_configured(path).with('log.cleaner.io.buffer.size')
        end

        it 'does not set cleaner io buffer load factor' do
          expect(chef_run).not_to have_configured(path).with('log.cleaner.io.buffer.load.factor')
        end

        it 'does not set cleaner backoff (milliseconds)' do
          expect(chef_run).not_to have_configured(path).with('log.cleaner.backoff.ms')
        end

        it 'does not set cleaner min cleanable ratio' do
          expect(chef_run).not_to have_configured(path).with('log.cleaner.min.cleanable.ratio')
        end

        it 'does not set cleaner delete retention ms' do
          expect(chef_run).not_to have_configured(path).with('log.cleaner.delete.retention.ms')
        end
      end

      context 'replication configuration' do
        it 'does not set controller socket timeout' do
          expect(chef_run).not_to have_configured(path).with('controller.socket.timeout.ms')
        end

        it 'does not set controller message queue size' do
          expect(chef_run).not_to have_configured(path).with('controller.message.queue.size')
        end

        it 'does not set default replication factor' do
          expect(chef_run).not_to have_configured(path).with('default.replication.factor')
        end

        it 'does not set replica lag time max (ms)' do
          expect(chef_run).not_to have_configured(path).with('replica.lag.time.max.ms')
        end

        it 'does not set replica message lag max' do
          expect(chef_run).not_to have_configured(path).with('replica.lag.max.messages')
        end

        it 'does not set replica socket timeout' do
          expect(chef_run).not_to have_configured(path).with('replica.socket.timeout.ms')
        end

        it 'does not set replica socket receive buffer bytes' do
          expect(chef_run).not_to have_configured(path).with('replica.socket.receive.buffer.bytes')
        end

        it 'does not set replica fetch max bytes' do
          expect(chef_run).not_to have_configured(path).with('replica.fetch.max.bytes')
        end

        it 'does not set replica fetch min bytes' do
          expect(chef_run).not_to have_configured(path).with('replica.fetch.min.bytes')
        end

        it 'does not set replica fetch max wait (ms)' do
          expect(chef_run).not_to have_configured(path).with('replica.fetch.wait.max.ms')
        end

        it 'does not set replica fetchers' do
          expect(chef_run).not_to have_configured(path).with('num.replica.fetchers')
        end

        it 'does not set replica high watermark checkpoint interval (ms)' do
          expect(chef_run).not_to have_configured(path).with('replica.high.watermark.checkpoint.interval.ms')
        end

        it 'does not set fetch purgatory purge interval' do
          expect(chef_run).not_to have_configured(path).with('fetch.purgatory.purge.interval.requests')
        end

        it 'does not set producer purgatory purge interval' do
          expect(chef_run).not_to have_configured(path).with('producer.purgatory.purge.interval.requests')
        end
      end

      context 'controlled shutdown configuration' do
        it 'does not set max retries' do
          expect(chef_run).not_to have_configured(path).with('controlled.shutdown.max.retries')
        end

        it 'does not set retry backoff (ms)' do
          expect(chef_run).not_to have_configured(path).with('controlled.shutdown.retry.backoff.ms')
        end

        it 'does not set value for enable' do
          expect(chef_run).not_to have_configured(path).with('controlled.shutdown.enable')
        end
      end

      context 'leader related configuration' do
        it 'does not set auto leader imbalance enable' do
          expect(chef_run).not_to have_configured(path).with('auto.leader.rebalance.enable')
        end

        it 'does not set leader imbalance per broker (percentage)' do
          expect(chef_run).not_to have_configured(path).with('leader.imbalance.per.broker.percentage')
        end

        it 'does not set leader imbalance check interval (seconds)' do
          expect(chef_run).not_to have_configured(path).with('leader.imbalance.check.interval.seconds')
        end

        it 'does not set offset metadata max (bytes)' do
          expect(chef_run).not_to have_configured(path).with('offset.metadata.max.bytes')
        end
      end

      context 'zookeeper configuration' do
        it 'does not set zookeeper connect' do
          expect(chef_run).not_to have_configured(path).with('zookeeper.connect')
        end

        it 'does not set zookeeper connection timeout' do
          expect(chef_run).not_to have_configured(path).with('zookeeper.connection.timeout.ms')
        end

        it 'does not set zookeeper session timeout' do
          expect(chef_run).not_to have_configured(path).with('zookeeper.session.timeout.ms')
        end

        it 'does not set zookeeper sync time (ms)' do
          expect(chef_run).not_to have_configured(path).with('zookeeper.sync.time.ms')
        end
      end
    end

    context 'explicit configuration' do
      let :kafka_attributes do
        {
          broker_id: 10002,
          message_max_bytes: 1_000_000,
          num_network_threads: 3,
          num_io_threads: 8,
          background_threads: 4,
          queued_max_requests: 500,
          port: 9092,
          host_name: 'host-name',
          advertised_host_name: 'advertised-host-name',
          advertised_port: 9092,
          socket: {
            send_buffer_bytes: 100 * 1024,
            receive_buffer_bytes: 100 * 1024,
            request_max_bytes: 100 * 1024 * 1024
          },
          num_partitions: 1,
          log: {
            dirs: ['/tmp/kafka-logs'],
            segment_bytes: 1024 * 1024 * 1024,
            roll_hours: 24 * 7,
            retention_minutes: 24 * 7 * 60,
            retention_hours: 24 * 7,
            retention_bytes: -1,
            retention_check_interval_ms: 60000,
            cleaner_enable: true,
            cleaner_threads: 8,
            cleaner_io_max_bytes_per_second: 10,
            cleaner_dedupe_buffer_size: 1000,
            cleaner_io_buffer_size: 50 * 1024,
            cleaner_io_buffer_load_factor: 0.8,
            cleaner_backoff_ms: 1500,
            cleaner_min_cleanable_ratio: 0.1,
            cleaner_delete_retention_ms: 1250,
            cleanup_interval_mins: 10,
            index_size_max_bytes: 10 * 1024 * 1024,
            index_interval_bytes: 4096,
            flush_interval_messages: 10_000,
            flush_interval_ms: 3000,
            flush_scheduler_interval_ms: 3000,
            delete_delay_ms: 1000,
            flush_offset_checkpoint_interval_ms: 1000,
            cleanup_policy: 'delete',
          },
          auto_create_topics: true,
          controller: {
            socket_timeout_ms: 30_000,
            message_queue_size: 10,
          },
          default_replication_factor: 1,
          replica: {
            lag_time_max_ms: 10_000,
            lag_max_messages: 4000,
            socket_timeout_ms: 30 * 1000,
            socket_receive_buffer_bytes: 64 * 1024,
            fetch_max_bytes: 1024 * 1024,
            fetch_wait_max_ms: 500,
            fetch_min_bytes: 1,
            high_watermark_checkpoint_interval_ms: 5000,
          },
          num_replica_fetchers: 1,
          fetch_purgatory_purge_interval_requests: 10_000,
          producer_purgatory_purge_interval_requests: 10_000,
          controlled_shutdown: {
            max_retries: 3,
            retry_backoff_ms: 5000,
            enabled: false,
          },
          auto_leader_rebalance_enable: true,
          leader: {
            imbalance_per_broker_percentage: 0.7,
            imbalance_check_interval_seconds: 3,
          },
          offset_metadata_max_bytes: 1000,
          zookeeper: {
            connect: [],
            connection_timeout_ms: 6000,
            session_timeout_ms: 6000,
            sync_time_ms: 2000,
          }
        }
      end

      context 'general configuration' do
        it 'sets broker id' do
          expect(chef_run).to have_configured(path).with('broker.id').as('10002')
        end

        it 'sets max bytes per message' do
          expect(chef_run).to have_configured(path).with('message.max.bytes').as(1_000_000)
        end

        it 'sets number of network threads' do
          expect(chef_run).to have_configured(path).with('num.network.threads').as(3)
        end

        it 'sets number of io threads' do
          expect(chef_run).to have_configured(path).with('num.io.threads').as(8)
        end

        context 'when kafka 0.8.0' do
          let :kafka_version do
            '0.8.0'
          end

          it 'does not set background threads' do
            expect(chef_run).not_to have_configured(path).with('background.threads').as(4)
          end
        end

        it 'sets number of background threads' do
          expect(chef_run).to have_configured(path).with('background.threads').as(4)
        end

        it 'sets queued max requests' do
          expect(chef_run).to have_configured(path).with('queued.max.requests').as(500)
        end
      end

      context 'socket server configuration' do
        it 'sets port' do
          expect(chef_run).to have_configured(path).with('port').as(9092)
        end

        it 'sets host name from node hostname attribute' do
          expect(chef_run).to have_configured(path).with('host.name').as('host-name')
        end

        context 'when kafka 0.8.0' do
          let :kafka_version do
            '0.8.0'
          end

          it 'does not configure advertised host.name attribute' do
            expect(chef_run).not_to have_configured(path).with('advertised.host.name').as('advertised-host-name')
          end

          it 'does not configure advertised port attribute' do
            expect(chef_run).not_to have_configured(path).with('advertised.port').as(9092)
          end
        end

        context 'when kafka > 0.8.0' do
          it 'configures advertised host.name attribute' do
            expect(chef_run).to have_configured(path).with('advertised.host.name').as('advertised-host-name')
          end

          it 'configures advertised port attribute' do
            expect(chef_run).to have_configured(path).with('advertised.port').as(9092)
          end
        end

        it 'sets send buffer bytes' do
          expect(chef_run).to have_configured(path).with('socket.send.buffer.bytes').as(100 * 1024)
        end

        it 'sets receive buffer bytes' do
          expect(chef_run).to have_configured(path).with('socket.receive.buffer.bytes').as(100 * 1024)
        end

        it 'sets receive request max size' do
          expect(chef_run).to have_configured(path).with('socket.request.max.bytes').as(100 * 1024 * 1024)
        end
      end

      context 'log configuration' do
        shared_examples_for 'a hash based option' do
          let :attribute do
            option.to_s.gsub('_', '.')
          end

          context 'by default' do
            context 'and kafka version is 0.8.0' do
              let :kafka_version do
                '0.8.0'
              end

              it 'configures a commented attribute' do
                expect(chef_run).to have_configured(path).with(%(#log.#{attribute})).as('')
              end
            end

            context 'and kafka version is > 0.8.0' do
              it 'ignores it' do
                expect(chef_run).not_to have_configured(path).with(%(#log.#{attribute})).as('')
              end
            end
          end

          context 'with a hash of mappings' do
            let :mappings do
              {'topic1' => 12345, 'topic2' => 3000}
            end

            before do
              kafka_attributes[:log].merge!({option => mappings})
            end

            context 'and kafka version is 0.8.0' do
              let :kafka_version do
                '0.8.0'
              end

              it 'transforms it to a CSV string' do
                expect(chef_run).to have_configured(path).with(%(log.#{attribute})).as('topic1:12345,topic2:3000')
              end
            end

            context 'and kafka version is > 0.8.0' do
              it 'ignores it' do
                expect(chef_run).not_to have_configured(path).with(%(log.#{attribute}))
              end
            end
          end
        end

        it 'sets number of partitions' do
          expect(chef_run).to have_configured(path).with('num.partitions').as(1)
        end

        it 'sets log dir(s)' do
          expect(chef_run).to have_configured(path).with('log.dirs').as('/tmp/kafka-logs')
        end

        it 'sets log segment bytes' do
          expect(chef_run).to have_configured(path).with('log.segment.bytes').as(1 * 1024 * 1024 * 1024)
        end

        context 'segment bytes per topic' do
          it_behaves_like 'a hash based option' do
            let :option do
              :segment_bytes_per_topic
            end
          end
        end

        it 'sets roll hours' do
          expect(chef_run).to have_configured(path).with('log.roll.hours').as(24 * 7)
        end

        context 'roll hours per topic' do
          it_behaves_like 'a hash based option' do
            let :option do
              :roll_hours_per_topic
            end
          end
        end

        context 'when kafka 0.8.0' do
          let :kafka_version do
            '0.8.0'
          end

          it 'sets log retention hours' do
            expect(chef_run).to have_configured(path).with('log.retention.hours').as(24 * 7)
          end

          it 'does not set log retention minutes' do
            expect(chef_run).not_to have_configured(path).with('log.retention.minutes')
          end
        end

        context 'when kafka > 0.8.0' do
          it 'does not set log retention hours' do
            expect(chef_run).not_to have_configured(path).with('log.retention.hours')
          end

          it 'sets log retention minutes' do
            expect(chef_run).to have_configured(path).with('log.retention.minutes').as(24 * 7 * 60)
          end
        end

        context 'log retention hours per topic' do
          it_behaves_like 'a hash based option' do
            let :option do
              :retention_hours_per_topic
            end
          end
        end

        it 'sets log retention bytes' do
          expect(chef_run).to have_configured(path).with('log.retention.bytes').as(-1)
        end

        context 'log retention bytes per topic' do
          it_behaves_like 'a hash based option' do
            let :option do
              :retention_bytes_per_topic
            end
          end
        end

        context 'when kafka 0.8.0' do
          let :kafka_version do
            '0.8.0'
          end

          it 'sets log cleanup interval (minutes)' do
            expect(chef_run).to have_configured(path).with('log.cleanup.interval.mins').as(10)
          end

          it 'does not set default log retention check interval (milliseconds)' do
            expect(chef_run).not_to have_configured(path).with('log.retention.check.interval.ms').as(60000)
          end

          it 'does not set delete delay ms' do
            expect(chef_run).not_to have_configured(path).with('log.delete.delay.ms')
          end

          it 'does not set flush offset checkpoint interval' do
            expect(chef_run).not_to have_configured(path).with('log.flush.offset.checkpoint.interval.ms')
          end

          it 'does not set cleanup policy' do
            expect(chef_run).not_to have_configured(path).with('log.cleanup.policy')
          end
        end

        context 'when kafka 0.8.1' do
          it 'does not set default log cleanup interval (minutes)' do
            expect(chef_run).not_to have_configured(path).with('log.cleanup.interval.mins').as(10)
          end

          it 'sets log retention check interval (milliseconds)' do
            expect(chef_run).to have_configured(path).with('log.retention.check.interval.ms').as(60000)
          end

          it 'sets delete delay ms' do
            expect(chef_run).to have_configured(path).with('log.delete.delay.ms').as(1000)
          end

          it 'sets flush offset checkpoint interval' do
            expect(chef_run).to have_configured(path).with('log.flush.offset.checkpoint.interval.ms').as(1000)
          end

          it 'sets cleanup policy' do
            expect(chef_run).to have_configured(path).with('log.cleanup.policy').as('delete')
          end
        end

        it 'sets max bytesize of index' do
          expect(chef_run).to have_configured(path).with('log.index.size.max.bytes').as(10 * 1024 * 1024)
        end

        it 'sets index interval bytes' do
          expect(chef_run).to have_configured(path).with('log.index.interval.bytes').as(4096)
        end

        it 'sets log flush interval (messages)' do
          expect(chef_run).to have_configured(path).with('log.flush.interval.messages').as(10_000)
        end

        it 'sets log flush interval (ms)' do
          expect(chef_run).to have_configured(path).with('log.flush.interval.ms').as(3000)
        end

        context 'log flush interval (ms) per topic' do
          it_behaves_like 'a hash based option' do
            let :option do
              :flush_interval_ms_per_topic
            end
          end
        end

        it 'sets log flush scheduler interval (ms)' do
          expect(chef_run).to have_configured(path).with('log.flush.scheduler.interval.ms').as(3000)
        end

        it 'automatically creates topics' do
          expect(chef_run).to have_configured(path).with('auto.create.topics.enable').as(true)
        end
      end

      context 'log cleaner configuration' do
        context 'when kafka 0.8.0' do
          let :kafka_version do
            '0.8.0'
          end

          it 'does not set cleaner enable' do
            expect(chef_run).not_to have_configured(path).with('log.cleaner.enable')
          end

          it 'does not set cleaner threads' do
            expect(chef_run).not_to have_configured(path).with('log.cleaner.threads')
          end

          it 'does not set cleaner io max bytes per second' do
            expect(chef_run).not_to have_configured(path).with('log.cleaner.io.max.bytes.per.second')
          end

          it 'does not set cleaner dedupe buffer size' do
            expect(chef_run).not_to have_configured(path).with('log.cleaner.dedupe.buffer.size')
          end

          it 'does not set cleaner io buffer size' do
            expect(chef_run).not_to have_configured(path).with('log.cleaner.io.buffer.size')
          end

          it 'does not set cleaner io buffer load factor' do
            expect(chef_run).not_to have_configured(path).with('log.cleaner.io.buffer.load.factor')
          end

          it 'does not set cleaner backoff (milliseconds)' do
            expect(chef_run).not_to have_configured(path).with('log.cleaner.backoff.ms')
          end

          it 'does not set cleaner min cleanable ratio' do
            expect(chef_run).not_to have_configured(path).with('log.cleaner.min.cleanable.ratio')
          end

          it 'does not set cleaner delete retention ms' do
            expect(chef_run).not_to have_configured(path).with('log.cleaner.delete.retention.ms')
          end
        end

        context 'when kafka > 0.8.0' do
          it 'sets cleaner enable' do
            expect(chef_run).to have_configured(path).with('log.cleaner.enable').as(true)
          end

          it 'sets cleaner threads' do
            expect(chef_run).to have_configured(path).with('log.cleaner.threads').as(8)
          end

          it 'sets cleaner io max bytes per second' do
            expect(chef_run).to have_configured(path).with('log.cleaner.io.max.bytes.per.second').as(10)
          end

          it 'sets cleaner dedupe buffer size' do
            expect(chef_run).to have_configured(path).with('log.cleaner.dedupe.buffer.size').as(1000)
          end

          it 'sets cleaner io buffer size' do
            expect(chef_run).to have_configured(path).with('log.cleaner.io.buffer.size').as(50 * 1024)
          end

          it 'sets cleaner io buffer load factor' do
            expect(chef_run).to have_configured(path).with('log.cleaner.io.buffer.load.factor').as(0.8)
          end

          it 'sets cleaner backoff (milliseconds)' do
            expect(chef_run).to have_configured(path).with('log.cleaner.backoff.ms').as(1500)
          end

          it 'sets cleaner min cleanable ratio' do
            expect(chef_run).to have_configured(path).with('log.cleaner.min.cleanable.ratio').as(0.1)
          end

          it 'sets cleaner delete retention ms' do
            expect(chef_run).to have_configured(path).with('log.cleaner.delete.retention.ms').as(1250)
          end
        end
      end

      context 'replication configuration' do
        it 'sets controller socket timeout' do
          expect(chef_run).to have_configured(path).with('controller.socket.timeout.ms').as(30_000)
        end

        it 'sets controller message queue size' do
          expect(chef_run).to have_configured(path).with('controller.message.queue.size').as(10)
        end

        it 'sets replication factor' do
          expect(chef_run).to have_configured(path).with('default.replication.factor').as(1)
        end

        it 'sets replica lag time max (ms)' do
          expect(chef_run).to have_configured(path).with('replica.lag.time.max.ms').as(10_000)
        end

        it 'sets replica message lag max' do
          expect(chef_run).to have_configured(path).with('replica.lag.max.messages').as(4000)
        end

        it 'sets replica socket timeout' do
          expect(chef_run).to have_configured(path).with('replica.socket.timeout.ms').as(30 * 1000)
        end

        it 'sets replica socket receive buffer bytes' do
          expect(chef_run).to have_configured(path).with('replica.socket.receive.buffer.bytes').as(64 * 1024)
        end

        it 'sets replica fetch max bytes' do
          expect(chef_run).to have_configured(path).with('replica.fetch.max.bytes').as(1024 * 1024)
        end

        it 'sets replica fetch min bytes' do
          expect(chef_run).to have_configured(path).with('replica.fetch.min.bytes').as(1)
        end

        it 'sets replica fetch max wait (ms)' do
          expect(chef_run).to have_configured(path).with('replica.fetch.wait.max.ms').as(500)
        end

        it 'sets replica fetchers' do
          expect(chef_run).to have_configured(path).with('num.replica.fetchers').as(1)
        end

        it 'sets replica high watermark checkpoint interval (ms)' do
          expect(chef_run).to have_configured(path).with('replica.high.watermark.checkpoint.interval.ms').as(5000)
        end

        it 'sets fetch purgatory purge interval' do
          expect(chef_run).to have_configured(path).with('fetch.purgatory.purge.interval.requests').as(10_000)
        end

        it 'sets producer purgatory purge interval' do
          expect(chef_run).to have_configured(path).with('producer.purgatory.purge.interval.requests').as(10_000)
        end
      end

      context 'controlled shutdown configuration' do
        it 'sets max retries' do
          expect(chef_run).to have_configured(path).with('controlled.shutdown.max.retries').as(3)
        end

        it 'sets retry backoff (ms)' do
          expect(chef_run).to have_configured(path).with('controlled.shutdown.retry.backoff.ms').as(5000)
        end

        it 'sets value for enable' do
          expect(chef_run).to have_configured(path).with('controlled.shutdown.enable').as(false)
        end
      end

      context 'leader related configuration' do
        context 'when kafka 0.8.0' do
          let :kafka_version do
            '0.8.0'
          end

          it 'does not set auto leader imbalance enable' do
            expect(chef_run).not_to have_configured(path).with('auto.leader.rebalance.enable').as(true)
          end

          it 'does not set leader imbalance per broker (percentage)' do
            expect(chef_run).not_to have_configured(path).with('leader.imbalance.per.broker.percentage').as(0.7)
          end

          it 'does not set leader imbalance check interval (seconds)' do
            expect(chef_run).not_to have_configured(path).with('leader.imbalance.check.interval.seconds').as(3)
          end
        end

        context 'when kafka > 0.8.0' do
          it 'sets auto leader imbalance enable' do
            expect(chef_run).to have_configured(path).with('auto.leader.rebalance.enable').as(true)
          end

          it 'sets leader imbalance per broker (percentage)' do
            expect(chef_run).to have_configured(path).with('leader.imbalance.per.broker.percentage').as(0.7)
          end

          it 'sets leader imbalance check interval (seconds)' do
            expect(chef_run).to have_configured(path).with('leader.imbalance.check.interval.seconds').as(3)
          end
        end
      end

      context 'consumer offset management configuration' do
        context 'when kafka 0.8.0' do
          let :kafka_version do
            '0.8.0'
          end

          it 'does not set offset metadata max (bytes)' do
            expect(chef_run).not_to have_configured(path).with('offset.metadata.max.bytes').as(1000)
          end
        end

        context 'when kafka > 0.8.0' do
          it 'sets offset metadata max (bytes)' do
            expect(chef_run).to have_configured(path).with('offset.metadata.max.bytes').as(1000)
          end
        end
      end

      context 'zookeeper configuration' do
        let :chef_run do
          ChefSpec::Runner.new do |node|
            node.set[:kafka][:zookeeper] = zookeeper_attrs
          end.converge(described_recipe)
        end

        let :zookeeper_attrs do
          {
            connect: %w(127.0.0.1),
            connection_timeout_ms: 6000,
            session_timeout_ms: 6000,
            sync_time_ms: 2000,
          }
        end

        context 'when zookeeper.path is not set' do
          it 'just sets hosts' do
            expect(chef_run).to have_configured(path).with('zookeeper.connect').as('127.0.0.1')
          end
        end

        context 'when zookeeper.path is set' do
          let :zookeeper_attrs do
            {connect: %w(127.0.0.1 127.0.0.2), path: '/test'}
          end

          it 'includes the path as well' do
            expect(chef_run).to have_configured(path).with('zookeeper.connect').as('127.0.0.1,127.0.0.2/test')
          end

          it 'does not require the path to start with a slash' do
            zookeeper_attrs[:path].gsub!('/', '')

            expect(chef_run).to have_configured(path).with('zookeeper.connect').as('127.0.0.1,127.0.0.2/test')
          end
        end

        it 'sets zookeeper connection timeout' do
          expect(chef_run).to have_configured(path).with('zookeeper.connection.timeout.ms').as(6000)
        end

        it 'sets zookeeper session timeout' do
          expect(chef_run).to have_configured(path).with('zookeeper.session.timeout.ms').as(6000)
        end

        it 'sets zookeeper sync time (ms)' do
          expect(chef_run).to have_configured(path).with('zookeeper.sync.time.ms').as(2000)
        end
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
      ChefSpec::Runner.new(platform_and_version) do |node|
        node.set[:kafka][:scala_version] = '2.8.0'
        node.set[:kafka][:init_style] = init_style
      end.converge(described_recipe)
    end

    let :platform_and_version do
      {}
    end

    let :script_permissions do
      '755'
    end

    it 'creates a script at the appropriate location' do
      expect(chef_run).to create_template(init_path).with({
        owner: 'root',
        group: 'root',
        mode: script_permissions,
        source: source_template,
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

        let :source_template do
          'sysv/default.erb'
        end
      end

      context 'and platform is \'ubuntu\'' do
        it_behaves_like 'an init style' do
          let :platform_and_version do
            {platform: 'ubuntu', version: '13.10'}
          end

          let :init_style do
            'sysv'
          end

          let :init_path do
            '/etc/init.d/kafka'
          end

          let :env_path do
            '/etc/default/kafka'
          end

          let :source_template do
            'sysv/debian.erb'
          end
        end
      end

      context 'and platform is \'debian\'' do
        it_behaves_like 'an init style' do
          let :platform_and_version do
            {platform: 'debian', version: '7.2'}
          end

          let :init_style do
            'sysv'
          end

          let :init_path do
            '/etc/init.d/kafka'
          end

          let :env_path do
            '/etc/default/kafka'
          end

          let :source_template do
            'sysv/debian.erb'
          end
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

        let :source_template do
          'upstart/default.erb'
        end
      end
    end
  end

  it 'enables a \'kafka\' service' do
    expect(chef_run).to enable_service('kafka')
  end
end
