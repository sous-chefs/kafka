#
# Cookbook Name:: kafka
# Libraries:: env
#

module Kafka
  class Env
    def initialize(attributes)
      @attributes = attributes
    end

    def to_h
      hash = {}
      ATTR_ENV_MAPPINGS.each do |attr_name, env_name|
        value = @attributes[attr_name]
        env_name ||= format('KAFKA_%s', attr_name.upcase)
        hash[env_name] = (value.respond_to?(:call) ? value.call : value).to_s
      end
      hash['KAFKA_RUN'] = ::File.join(@attributes['install_dir'], 'bin', 'kafka-run-class.sh')
      hash['KAFKA_ARGS'] = 'kafka.Kafka'
      hash['KAFKA_CONFIG'] = ::File.join(@attributes['config_dir'], 'server.properties')
      hash
    end

    def to_file_content(export)
      variables = to_h.map do |key, value|
        variable = format('%s=%p', key, value.to_s)
        variable = export ? format('export %s', variable) : variable
        variable
      end
      variables.join($/)
    end

    ATTR_ENV_MAPPINGS ||= {
      'scala_version' => 'SCALA_VERSION',
      'generic_opts' => 'KAFKA_OPTS',
      'jmx_port' => 'JMX_PORT',
      'jvm_performance_opts' => nil,
      'gc_log_opts' => nil,
      'log4j_opts' => nil,
      'heap_opts' => nil,
      'jmx_opts' => nil,
    }.freeze
  end
end
