# encoding: utf-8

require 'spec_helper'

describe 'kafka::_configure' do
  let :chef_run do
    ChefSpec::Runner.new do |node|
      node.set[:kafka] = kafka_attributes
      node.set[:kafka][:broker] = broker_attributes
    end.converge(*described_recipes)
  end

  let :described_recipes do
    ['kafka::_defaults', described_recipe]
  end

  let :node do
    chef_run.node
  end

  let :kafka_attributes do
    {}
  end

  let :broker_attributes do
    {}
  end

  it 'creates config directory' do
    expect(chef_run).to create_directory('/opt/kafka/config').with({
      owner: 'kafka',
      group: 'kafka',
      mode: '755'
    })
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
      it 'sets broker id from node\'s ip address' do
        expect(chef_run).to have_configured(path).with('broker.id').as('10002')
      end

      it 'sets port' do
        expect(chef_run).to have_configured(path).with('port').as(6667)
      end

      context 'when broker id is larger than 2**31' do
        let :chef_run do
          ChefSpec::Runner.new do |node|
            node.automatic[:ipaddress] = '255.255.255.255'
          end.converge(*described_recipes)
        end

        it 'mod\'s it by 2**31' do
          expect(chef_run).to have_configured(path).with('broker.id').as('1852184791')
        end
      end
    end

    shared_examples_for 'when value is an Array' do |attr_key|
      let :mappings do
        %w[topic1 topic2]
      end

      it 'joins elements using #to_s and a comma' do
        expect(chef_run).to have_configured(path).with('array.option').as('topic1,topic2')
      end
    end

    shared_examples_for 'when configuration name contains both `_` and `.`' do
      let :mappings do
        'contains underscore'
      end

      it 'does not transform underscores to dots' do
        expect(chef_run).to have_configured(path).with('possible.future_option').as('contains underscore')
      end
    end

    context 'configuration using underscore notation' do
      it_behaves_correctly 'when value is an Array' do
        let :broker_attributes do
          {array_option: mappings}
        end
      end

      it_behaves_correctly 'when configuration name contains both `_` and `.`' do
        let :broker_attributes do
          {:'possible.future_option' => mappings}
        end
      end
    end

    context 'configuration using dotted String notation' do
      it_behaves_correctly 'when value is an Array' do
        let :broker_attributes do
          {'array.option' => mappings}
        end
      end

      it_behaves_correctly 'when configuration name contains both `_` and `.`' do
        let :broker_attributes do
          {'possible.future_option' => mappings}
        end
      end
    end

    context 'configuration using nested Hashes notation' do
      it_behaves_correctly 'when value is an Array' do
        let :broker_attributes do
          { array: { option: mappings } }
        end
      end

      it_behaves_correctly 'when configuration name contains both `_` and `.`' do
        let :broker_attributes do
          { possible: { :'future_option' => mappings } }
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
      expect(chef_run).to have_configured(path).with('log4j.appender.kafkaAppender.DatePattern').as('.yyyy-MM-dd')
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

    it 'configures sane date patterns for appenders' do
      expect(node.kafka.log4j.appenders).to_not be_empty
      node.kafka.log4j.appenders.each do |_, opts|
        expect(opts.date_pattern).to eq('.yyyy-MM-dd')
      end
    end
  end

  shared_examples_for 'an init style' do
    let :chef_run do
      ChefSpec::Runner.new(platform_and_version) do |node|
        node.set[:kafka][:scala_version] = '2.8.0'
        node.set[:kafka][:init_style] = init_style
        node.set[:kafka][:broker] = broker_attributes
      end.converge(*described_recipes)
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

      it 'sets KAFKA_JMX_OPTS' do
        expect(chef_run).to have_configured(env_path).with('(export |)KAFKA_JMX_OPTS').as('"-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"')
      end

      it 'sets KAFKA_LOG4J_OPTS' do
        expect(chef_run).to have_configured(env_path).with('(export |)KAFKA_LOG4J_OPTS').as('"-Dlog4j.configuration=file:/opt/kafka/config/log4j.properties"')
      end

      it 'sets KAFKA_HEAP_OPTS' do
        expect(chef_run).to have_configured(env_path).with('(export |)KAFKA_HEAP_OPTS').as('"-Xmx1G -Xms1G"')
      end

      it 'sets KAFKA_GC_LOG_OPTS' do
        expect(chef_run).to have_configured(env_path).with('(export |)KAFKA_GC_LOG_OPTS').as('"-Xloggc:/var/log/kafka/kafka-gc.log -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps"')
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

        context 'and platform is \'debian\'' do
          it_behaves_like 'an init style' do
            let :platform_and_version do
              {platform: 'debian', version: '7.2'}
            end

            let :init_style do
              'systemd'
            end

            let :init_path do
              '/etc/systemd/system/kafka.service'
            end

            let :env_path do
              '/etc/default/kafka'
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
            expect(template).not_to notify('ruby_block[coordinate-kafka-start]').to(:create)
          end
        end
      end

      context 'when set to true' do
        let :kafka_attributes do
          {automatic_restart: true}
        end

        it 'restarts kafka when configuration is changed' do
          config_templates.each do |template|
            expect(template).to notify('ruby_block[coordinate-kafka-start]').to(:create)
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

    context 'coordination recipe' do
      it 'includes a recipe for coordinating starts / restarts' do
        expect(chef_run).to include_recipe('kafka::_coordinate')
      end

      it 'creates a ruby_block that does nothing' do
        expect(chef_run.ruby_block('coordinate-kafka-start')).to do_nothing
      end
    end
  end
end
