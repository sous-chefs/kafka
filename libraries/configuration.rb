#
# Cookbook Name:: kafka
# Libraries:: configuration
#

module Kafka
  module Configuration
    def render_option?(value)
      if value.is_a?(Array)
        !value.empty?
      elsif value.is_a?(Hash)
        value.values.all? do |v|
          render_option?(v)
        end
      else
        !value.nil?
      end
    end

    def render_option(key, value)
      if value.is_a?(Array)
        %(#{key}=#{render_array_value(value)})
      elsif value.is_a?(Hash)
        %(#{key}=#{render_hash_value(value).join(',')})
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
