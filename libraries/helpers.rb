# frozen_string_literal: true

require 'digest'

module Kafka
  module Helpers
    def kafka_version_name(resource = new_resource)
      "kafka_#{resource.scala_version}-#{resource.version}"
    end

    def kafka_archive_name(resource = new_resource)
      "#{kafka_version_name(resource)}.tgz"
    end

    def kafka_archive_path(resource = new_resource)
      ::File.join(Chef::Config[:file_cache_path], kafka_archive_name(resource))
    end

    def kafka_download_url(resource = new_resource)
      [resource.base_url, resource.version, kafka_archive_name(resource)].join('/')
    end

    def kafka_jar_path(resource = new_resource)
      ::File.join(resource.version_install_dir, 'libs', "#{kafka_version_name(resource)}.jar")
    end

    def kafka_installed?(resource = new_resource)
      ::File.exist?(resource.version_install_dir) && ::File.exist?(kafka_jar_path(resource))
    end

    def kafka_log_dirs(resource = new_resource)
      value = resource.broker_config['log.dirs'] || resource.broker_config[:'log.dirs'] || resource.broker_config[:log_dirs]
      Array(value).flat_map { |entry| entry.to_s.split(',') }.map(&:strip).reject(&:empty?)
    end

    def kafka_normalize_checksum(value)
      value.to_s.delete(' ').downcase
    end

    def kafka_validate_checksum!(path, algorithm, expected)
      return if expected.nil? || expected.empty?

      actual = Digest.const_get(algorithm).file(path).hexdigest
      return if actual == kafka_normalize_checksum(expected)

      raise "Downloaded tarball #{algorithm} checksum (#{actual}) does not match #{expected}"
    end

    def kafka_default_log4j_config(resource = new_resource)
      {
        'root_logger' => 'INFO, kafkaAppender',
        'appenders' => {
          'kafkaAppender' => {
            'type' => 'org.apache.log4j.DailyRollingFileAppender',
            'date_pattern' => '.yyyy-MM-dd',
            'file' => ::File.join(resource.log_dir, 'kafka.log'),
            'layout' => {
              'type' => 'org.apache.log4j.PatternLayout',
              'conversion_pattern' => '[%d] %p %m (%c)%n',
            },
          },
          'stateChangeAppender' => {
            'type' => 'org.apache.log4j.DailyRollingFileAppender',
            'date_pattern' => '.yyyy-MM-dd',
            'file' => ::File.join(resource.log_dir, 'kafka-state-change.log'),
            'layout' => {
              'type' => 'org.apache.log4j.PatternLayout',
              'conversion_pattern' => '[%d] %p %m (%c)%n',
            },
          },
          'requestAppender' => {
            'type' => 'org.apache.log4j.DailyRollingFileAppender',
            'date_pattern' => '.yyyy-MM-dd',
            'file' => ::File.join(resource.log_dir, 'kafka-request.log'),
            'layout' => {
              'type' => 'org.apache.log4j.PatternLayout',
              'conversion_pattern' => '[%d] %p %m (%c)%n',
            },
          },
          'controllerAppender' => {
            'type' => 'org.apache.log4j.DailyRollingFileAppender',
            'date_pattern' => '.yyyy-MM-dd',
            'file' => ::File.join(resource.log_dir, 'kafka-controller.log'),
            'layout' => {
              'type' => 'org.apache.log4j.PatternLayout',
              'conversion_pattern' => '[%d] %p %m (%c)%n',
            },
          },
        },
        'loggers' => {
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

    def kafka_env_hash(resource = new_resource)
      {
        'SCALA_VERSION' => resource.scala_version,
        'JMX_PORT' => resource.jmx_port,
        'KAFKA_LOG4J_OPTS' => resource.log4j_opts,
        'KAFKA_HEAP_OPTS' => resource.heap_opts,
        'KAFKA_GC_LOG_OPTS' => resource.gc_log_opts,
        'KAFKA_OPTS' => resource.generic_opts,
        'KAFKA_JVM_PERFORMANCE_OPTS' => resource.jvm_performance_opts,
        'KAFKA_JMX_OPTS' => resource.jmx_opts,
      }.transform_values { |value| value.nil? ? '' : value.to_s }
    end

    def kafka_env_content(resource = new_resource)
      kafka_env_hash(resource).map { |key, value| format('%s=%p', key, value) }.join("\n") << "\n"
    end

    def kafka_systemd_content(resource = new_resource)
      service = {
        'Type' => 'simple',
        'User' => resource.user,
        'Group' => resource.group,
        'EnvironmentFile' => resource.env_path,
        'ExecStart' => "#{::File.join(resource.install_dir, 'bin', 'kafka-server-start.sh')} #{::File.join(resource.config_dir, 'server.properties')}",
        'ExecStop' => ::File.join(resource.install_dir, 'bin', 'kafka-server-stop.sh'),
        'TimeoutStopSec' => resource.kill_timeout.to_s,
        'Restart' => 'on-failure',
      }
      service['LimitNOFILE'] = resource.ulimit_file.to_s if resource.ulimit_file

      {
        'Unit' => {
          'Description' => 'Apache Kafka broker',
          'Wants' => 'network-online.target',
          'After' => 'network-online.target',
        },
        'Service' => service,
        'Install' => {
          'WantedBy' => 'multi-user.target',
        },
      }
    end
  end
end
