# encoding: utf-8

require 'spec_helper'

describe 'kafka::_configure' do
  let :chef_run do
    ChefSpec::Runner.new do |node|
      node.set[:kafka] = kafka_attributes
      node.set[:kafka][:broker] = broker_attributes
      node.set[:kafka][:version] = kafka_version
    end.converge(described_recipe)
  end

  let :kafka_version do
    '0.8.1'
  end

  let :kafka_attributes do
    {}
  end

  let :broker_attributes do
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

    context 'configuration types' do
      context 'Array-based option' do
        before do
          broker_attributes[:array_option] = %w[topic1 topic2]
        end

        it 'joins elements using comma' do
          expect(chef_run).to have_configured(path).with('array.option').as('topic1,topic2')
        end
      end

      context 'Hash-based option' do
        let :mappings do
          {'topic1' => 12345, 'topic2' => 3000}
        end

        before do
          broker_attributes[:hash_option] = mappings
        end

        it 'transforms it to a CSV string' do
          expect(chef_run).to have_configured(path).with('hash.option').as('topic1:12345,topic2:3000')
        end
      end

      context 'true / false option' do
        before do
          broker_attributes[:false_option] = false
          broker_attributes[:true_option] = true
        end

        it 'uses the #to_s representation' do
          expect(chef_run).to have_configured(path).with('false.option').as('false')
          expect(chef_run).to have_configured(path).with('true.option').as('true')
        end
      end

      context 'Fixnum option' do
        before do
          broker_attributes[:port] = 12345
        end

        it 'uses the #to_s representation' do
          expect(chef_run).to have_configured(path).with('port').as('12345')
        end
      end

      context 'string option' do
        before do
          broker_attributes[:log_cleanup_policy] = 'compact'
        end

        it 'uses it as-is' do
          expect(chef_run).to have_configured(path).with('log.cleanup.policy').as('compact')
        end
      end

      context 'symbol option' do
        before do
          broker_attributes[:log_cleanup_policy] = :compact
        end

        it 'uses the #to_s representation' do
          expect(chef_run).to have_configured(path).with('log.cleanup.policy').as('compact')
        end
      end
    end

    context 'default configuration' do
      it 'sets broker id from node\'s ip address' do
        expect(chef_run).to have_configured(path).with('broker.id').as('10002')
      end

      it 'sets port' do
        expect(chef_run).to have_configured(path).with('port').as(6667)
      end

      it 'sets host.name' do
        expect(chef_run).to have_configured(path).with('host.name').as('Fauxhai')
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
    end

    context 'explicit configuration' do
      let :broker_attributes do
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
          socket_send_buffer_bytes: 100 * 1024,
          socket_receive_buffer_bytes: 100 * 1024,
          socket_request_max_bytes: 100 * 1024 * 1024,
          num_partitions: 1,
          log_dirs: ['/tmp/kafka-logs-1', '/tmp/kafka-logs-2'],
          log_segment_bytes: 1024 * 1024 * 1024,
          log_roll_hours: 24 * 7,
          log_retention_minutes: 24 * 7 * 60,
          log_retention_hours: 24 * 7,
          log_retention_bytes: -1,
          log_retention_check_interval_ms: 60000,
          log_cleaner_enable: true,
          log_cleaner_threads: 8,
          log_cleaner_io_max_bytes_per_second: 10,
          log_cleaner_dedupe_buffer_size: 1000,
          log_cleaner_io_buffer_size: 50 * 1024,
          log_cleaner_io_buffer_load_factor: 0.8,
          log_cleaner_backoff_ms: 1500,
          log_cleaner_min_cleanable_ratio: 0.1,
          log_cleaner_delete_retention_ms: 1250,
          log_cleanup_interval_mins: 10,
          log_index_size_max_bytes: 10 * 1024 * 1024,
          log_index_interval_bytes: 4096,
          log_flush_interval_messages: 10_000,
          log_flush_interval_ms: 3000,
          log_flush_scheduler_interval_ms: 3000,
          log_delete_delay_ms: 1000,
          log_flush_offset_checkpoint_interval_ms: 1000,
          log_cleanup_policy: 'delete',
          auto_create_topics_enable: true,
          controller_socket_timeout_ms: 30_000,
          controller_message_queue_size: 10,
          default_replication_factor: 1,
          replica_lag_time_max_ms: 10_000,
          replica_lag_max_messages: 4000,
          replica_socket_timeout_ms: 30 * 1000,
          replica_socket_receive_buffer_bytes: 64 * 1024,
          replica_fetch_max_bytes: 1024 * 1024,
          replica_fetch_wait_max_ms: 500,
          replica_fetch_min_bytes: 1,
          replica_high_watermark_checkpoint_interval_ms: 5000,
          num_replica_fetchers: 1,
          fetch_purgatory_purge_interval_requests: 10_000,
          producer_purgatory_purge_interval_requests: 10_000,
          controlled_shutdown_max_retries: 3,
          controlled_shutdown_retry_backoff_ms: 5000,
          controlled_shutdown_enable: false,
          auto_leader_rebalance_enable: true,
          leader_imbalance_per_broker_percentage: 0.7,
          leader_imbalance_check_interval_seconds: 3,
          offset_metadata_max_bytes: 1000,
          zookeeper_connect: [],
          zookeeper_connection_timeout_ms: 6000,
          zookeeper_session_timeout_ms: 6000,
          zookeeper_sync_time_ms: 2000,
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

        it 'configures advertised host.name attribute' do
          expect(chef_run).to have_configured(path).with('advertised.host.name').as('advertised-host-name')
        end

        it 'configures advertised port attribute' do
          expect(chef_run).to have_configured(path).with('advertised.port').as(9092)
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
        it 'sets number of partitions' do
          expect(chef_run).to have_configured(path).with('num.partitions').as(1)
        end

        it 'sets log dir(s)' do
          expect(chef_run).to have_configured(path).with('log.dirs').as("/tmp/kafka-logs-1,/tmp/kafka-logs-2")
        end

        it 'sets log segment bytes' do
          expect(chef_run).to have_configured(path).with('log.segment.bytes').as(1 * 1024 * 1024 * 1024)
        end

        it 'sets roll hours' do
          expect(chef_run).to have_configured(path).with('log.roll.hours').as(24 * 7)
        end

        it 'sets log retention minutes' do
          expect(chef_run).to have_configured(path).with('log.retention.minutes').as(24 * 7 * 60)
        end

        it 'sets log retention bytes' do
          expect(chef_run).to have_configured(path).with('log.retention.bytes').as(-1)
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

        it 'sets log flush scheduler interval (ms)' do
          expect(chef_run).to have_configured(path).with('log.flush.scheduler.interval.ms').as(3000)
        end

        it 'automatically creates topics' do
          expect(chef_run).to have_configured(path).with('auto.create.topics.enable').as(true)
        end
      end

      context 'log cleaner configuration' do
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

      context 'consumer offset management configuration' do
        it 'sets offset metadata max (bytes)' do
          expect(chef_run).to have_configured(path).with('offset.metadata.max.bytes').as(1000)
        end
      end

      context 'zookeeper configuration' do
        let :broker_attrs do
          {
            zookeeper_connect: %w(127.0.0.1),
            zookeeper_connection_timeout_ms: 6000,
            zookeeper_session_timeout_ms: 6000,
            zookeeper_sync_time_ms: 2000,
          }
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

    it 'configures root logger' do
      expect(chef_run).to have_configured(path).with('log4j.rootLogger').as('INFO, kafkaAppender')
    end

    it 'configures appenders' do
      expect(chef_run).to have_configured(path).with('log4j.appender.kafkaAppender=org.apache.log4j.DailyRollingFileAppender')
      expect(chef_run).to have_configured(path).with('log4j.appender.kafkaAppender.DatePattern').as('"."yyyy-MM-dd')
      expect(chef_run).to have_configured(path).with('log4j.appender.stateChangeAppender=org.apache.log4j.DailyRollingFileAppender')
      expect(chef_run).to have_configured(path).with('log4j.appender.requestAppender=org.apache.log4j.DailyRollingFileAppender')
      expect(chef_run).to have_configured(path).with('log4j.appender.controllerAppender=org.apache.log4j.DailyRollingFileAppender')
    end

    it 'configures layouts' do
      expect(chef_run).to have_configured(path).with('log4j.appender.kafkaAppender.layout').as('org.apache.log4j.PatternLayout')
      expect(chef_run).to have_configured(path).with('log4j.appender.kafkaAppender.layout.ConversionPattern').as('[%d] %p %m (%c)%n')
    end

    it 'configures loggers' do
      expect(chef_run).to have_configured(path).with('log4j.logger.org.IOItec.zkclient.ZkClient').as('INFO')
      expect(chef_run).to have_configured(path).with('log4j.logger.kafka.network.RequestChannel\$').as('WARN, requestAppender')
      expect(chef_run).to have_configured(path).with('log4j.logger.kafka.request.logger').as('WARN, requestAppender')
      expect(chef_run).to have_configured(path).with('log4j.logger.kafka.controller').as('INFO, controllerAppender')
      expect(chef_run).to have_configured(path).with('log4j.logger.state.change.logger').as('INFO, stateChangeAppender')
    end

    it 'configures log path for FileAppenders' do
      expect(chef_run).to have_configured(path).with('log4j.appender.kafkaAppender.File').as('/var/log/kafka/kafka.log')
      expect(chef_run).to have_configured(path).with('log4j.appender.stateChangeAppender.File').as('/var/log/kafka/kafka-state-change.log')
      expect(chef_run).to have_configured(path).with('log4j.appender.requestAppender.File').as('/var/log/kafka/kafka-request.log')
      expect(chef_run).to have_configured(path).with('log4j.appender.controllerAppender.File').as('/var/log/kafka/kafka-controller.log')
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
        expect(chef_run).to have_configured(env_path).with('(export |)SCALA_VERSION').as('"2.8.0"')
      end

      it 'sets JMX_PORT' do
        expect(chef_run).to have_configured(env_path).with('(export |)JMX_PORT').as('"9999"')
      end

      it 'sets KAFKA_LOG4J_OPTS' do
        expect(chef_run).to have_configured(env_path).with('(export |)KAFKA_LOG4J_OPTS').as('"-Dlog4j.configuration=file:/opt/kafka/config/log4j.properties"')
      end

      it 'sets KAFKA_HEAP_OPTS' do
        expect(chef_run).to have_configured(env_path).with('(export |)KAFKA_HEAP_OPTS').as('"-Xmx1G -Xms1G"')
      end

      it 'sets KAFKA_GC_LOG_OPTS' do
        expect(chef_run).to have_configured(env_path).with('(export |)KAFKA_GC_LOG_OPTS').as('"-Xloggc:/var/log/kafka/kafka-gc.log -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps"')
      end

      it 'sets KAFKA_OPTS' do
        expect(chef_run).to have_configured(env_path).with('(export |)KAFKA_OPTS').as('""')
      end

      it 'sets KAFKA_JVM_PERFORMANCE_OPTS' do
        expect(chef_run).to have_configured(env_path).with('(export |)KAFKA_JVM_PERFORMANCE_OPTS').as('"-server -XX:+UseCompressedOops -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+CMSScavengeBeforeRemark -XX:+DisableExplicitGC -Djava.awt.headless=true"')
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

    context 'when init_style is :systemd' do
      it_behaves_like 'an init style' do
        let :init_style do
          'systemd'
        end

        let :init_path do
          '/etc/systemd/system/kafka.service'
        end

        let :env_path do
          '/etc/sysconfig/kafka'
        end

        let :script_permissions do
          '644'
        end

        let :source_template do
          'systemd/default.erb'
        end
      end
    end
  end

  context 'kafka service' do
    it 'enables a \'kafka\' service' do
      expect(chef_run).to enable_service('kafka')
    end

    context 'automatic_restart attribute' do
      let :config_paths do
        %w[/opt/kafka/config/server.properties /opt/kafka/config/log4j.properties /etc/sysconfig/kafka /etc/init.d/kafka]
      end

      let :config_templates do
        config_paths.map do |config_path|
          chef_run.template(config_path)
        end
      end

      context 'by default' do
        it 'does not restart kafka on configuration changes' do
          config_templates.each do |template|
            expect(template).not_to notify('service[kafka]').to(:restart)
          end
        end
      end

      context 'when set to true' do
        let :kafka_attributes do
          {automatic_restart: true}
        end

        it 'restarts kafka when configuration is changed' do
          config_templates.each do |template|
            expect(template).to notify('service[kafka]').to(:restart)
          end
        end

        it 'starts kafka' do
          expect(chef_run).to start_service('kafka')
        end
      end
    end

    context 'automatic_start attribute' do
      context 'by default' do
        it 'does not start kafka' do
          expect(chef_run).to_not start_service('kafka')
        end
      end

      context 'when set to true' do
        let :kafka_attributes do
          {automatic_start: true}
        end

        it 'starts kafka' do
          expect(chef_run).to start_service('kafka')
        end
      end
    end
  end
end
