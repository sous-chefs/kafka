#
# Cookbook Name:: kafka
# Libraries:: kafka_configuration
#

module Kafka
  module Configuration
    def convert_key(key)
      key.gsub('_', '.')
    end

    def convert_value(value)
      case value
      when Array
        value.join(',')
      when Hash
        value.map { |k, v| [k, v].join(':') }.join(',')
      else
        value.to_s
      end
    end

    def render_option(key, value)
      [convert_key(key), convert_value(value)].join('=')
    end
  end
end
