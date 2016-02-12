#
# Cookbook Name:: kafka
# Libraries:: configuration
#

module Kafka
  module Configuration
    def render_option?(value)
      case value
      when Hash
        value.values.all? do |v|
          render_option?(v)
        end
      when Array
        !value.empty?
      else
        !value.nil?
      end
    end

    def render_option(key, value)
      if value.is_a?(Array)
        %(#{key}=#{render_array_value(value)})
      else
        %(#{key}=#{value})
      end
    end

    private

    def render_array_value(values)
      vvs = values.flat_map do |v|
        v.is_a?(Hash) ? render_hash_value(v) : v.to_s
      end
      vvs.join(',')
    end

    def render_hash_value(hash)
      hash.map { |key, value| %(#{key}:#{value}) }
    end
  end
end
