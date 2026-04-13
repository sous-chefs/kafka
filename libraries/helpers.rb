# frozen_string_literal: true

module KafkaCookbook
  module Helpers
    def archive_name(resource)
      "#{kafka_version_name(resource)}.tgz"
    end

    def cached_archive_path(resource)
      ::File.join(Chef::Config[:file_cache_path], archive_name(resource))
    end

    def environment_file_path(resource)
      platform_family?('debian') ? "/etc/default/#{resource.service_name}" : "/etc/sysconfig/#{resource.service_name}"
    end

    def effective_log4j(resource)
      deep_merge(default_log4j(resource.log_dir), resource.log4j)
    end

    def kafka_installed?(resource)
      ::File.exist?(kafka_jar_path(resource))
    end

    def kafka_jar_path(resource)
      ::File.join(resource.version_install_dir, 'libs', "#{kafka_version_name(resource)}.jar")
    end

    def kafka_log_dirs(resource)
      Array(resource.broker['log.dirs'])
    end

    def kafka_version_name(resource)
      "kafka_#{resource.scala_version}-#{resource.version}"
    end

    def kraft_mode?(resource)
      resource.broker.key?('process.roles')
    end

    def service_actions(resource)
      actions = %i(create enable)
      actions << :start if start_automatically?(resource)
      actions
    end

    def start_automatically?(resource)
      !!resource.automatic_start || restart_on_configuration_change?(resource)
    end

    def restart_on_configuration_change?(resource)
      !!resource.automatic_restart
    end

    def remote_path(resource)
      [resource.base_url, resource.version, archive_name(resource)].join('/')
    end

    def storage_dir(resource)
      resource.broker['metadata.log.dir'] || kafka_log_dirs(resource).first
    end

    def service_unit_content(resource)
      content = {
        'Unit' => {
          'Description' => 'Apache Kafka broker',
          'Wants' => 'network-online.target',
          'After' => 'network-online.target',
        },
        'Service' => {
          'Type' => 'simple',
          'User' => resource.user,
          'Group' => resource.group,
          'EnvironmentFile' => environment_file_path(resource),
          'ExecStart' => "#{resource.install_dir}/bin/kafka-server-start.sh #{resource.config_dir}/server.properties",
          'ExecStop' => "#{resource.install_dir}/bin/kafka-server-stop.sh",
          'SyslogIdentifier' => resource.service_name,
          'TimeoutStopSec' => resource.kill_timeout.to_i,
        },
        'Install' => {
          'WantedBy' => 'multi-user.target',
        },
      }

      content['Service']['LimitNOFILE'] = resource.ulimit_file.to_i if resource.ulimit_file
      content
    end

    def default_log4j(log_dir)
      {
        'root_logger' => 'INFO, kafkaAppender',
        'appenders' => {
          'kafkaAppender' => {
            type: 'org.apache.log4j.DailyRollingFileAppender',
            date_pattern: '.yyyy-MM-dd',
            file: ::File.join(log_dir, 'kafka.log'),
            layout: {
              type: 'org.apache.log4j.PatternLayout',
              conversion_pattern: '[%d] %p %m (%c)%n',
            },
          },
          'stateChangeAppender' => {
            type: 'org.apache.log4j.DailyRollingFileAppender',
            date_pattern: '.yyyy-MM-dd',
            file: ::File.join(log_dir, 'kafka-state-change.log'),
            layout: {
              type: 'org.apache.log4j.PatternLayout',
              conversion_pattern: '[%d] %p %m (%c)%n',
            },
          },
          'requestAppender' => {
            type: 'org.apache.log4j.DailyRollingFileAppender',
            date_pattern: '.yyyy-MM-dd',
            file: ::File.join(log_dir, 'kafka-request.log'),
            layout: {
              type: 'org.apache.log4j.PatternLayout',
              conversion_pattern: '[%d] %p %m (%c)%n',
            },
          },
          'controllerAppender' => {
            type: 'org.apache.log4j.DailyRollingFileAppender',
            date_pattern: '.yyyy-MM-dd',
            file: ::File.join(log_dir, 'kafka-controller.log'),
            layout: {
              type: 'org.apache.log4j.PatternLayout',
              conversion_pattern: '[%d] %p %m (%c)%n',
            },
          },
        },
        'loggers' => {
          'org.IOItec.zkclient.ZkClient' => {
            'level' => 'INFO',
          },
          'kafka.network.RequestChannel$' => {
            'level' => 'WARN',
            'appender' => 'requestAppender',
            'additivity' => false,
          },
          'kafka.request.logger' => {
            'level' => 'WARN',
            'appender' => 'requestAppender',
            'additivity' => false,
          },
          'kafka.controller' => {
            'level' => 'INFO',
            'appender' => 'controllerAppender',
            'additivity' => false,
          },
          'state.change.logger' => {
            'level' => 'INFO',
            'appender' => 'stateChangeAppender',
            'additivity' => false,
          },
        },
      }
    end

    private

    def deep_merge(left, right)
      left.merge(right) do |_key, left_value, right_value|
        if left_value.is_a?(Hash) && right_value.is_a?(Hash)
          deep_merge(left_value, right_value)
        else
          right_value
        end
      end
    end
  end
end
