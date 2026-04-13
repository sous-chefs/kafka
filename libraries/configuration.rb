# frozen_string_literal: true

module KafkaCookbook
  module Configuration
    def render_option?(value)
      case value
      when Array
        !value.empty?
      when Hash
        value.values.all? { |entry| render_option?(entry) }
      else
        !value.nil?
      end
    end

    def render_option(key, value)
      case value
      when Array
        "#{key}=#{render_array_value(value)}"
      when Hash
        "#{key}=#{render_hash_value(value).join(',')}"
      else
        "#{key}=#{value}"
      end
    end

    private

    def render_array_value(values)
      values.flat_map { |value| value.is_a?(Hash) ? render_hash_value(value) : value.to_s }.join(',')
    end

    def render_hash_value(hash)
      hash.map { |key, value| "#{key}:#{value}" }
    end
  end
end
