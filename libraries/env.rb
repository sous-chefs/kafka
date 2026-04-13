# frozen_string_literal: true

module KafkaCookbook
  class Env
    ATTR_ENV_MAPPINGS = {
      'scala_version' => 'SCALA_VERSION',
      'generic_opts' => 'KAFKA_OPTS',
      'jmx_port' => 'JMX_PORT',
      'jvm_performance_opts' => 'KAFKA_JVM_PERFORMANCE_OPTS',
      'gc_log_opts' => 'KAFKA_GC_LOG_OPTS',
      'log4j_opts' => 'KAFKA_LOG4J_OPTS',
      'heap_opts' => 'KAFKA_HEAP_OPTS',
      'jmx_opts' => 'KAFKA_JMX_OPTS',
    }.freeze

    def initialize(attributes)
      @attributes = attributes
    end

    def to_h
      ATTR_ENV_MAPPINGS.each_with_object({}) do |(attribute_name, env_name), env_hash|
        value = @attributes[attribute_name]
        next if value.nil?

        env_hash[env_name] = value.to_s
      end
    end

    def to_file_content
      to_h.map { |key, value| %(#{key}="#{value}") }.join("\n")
    end
  end
end
