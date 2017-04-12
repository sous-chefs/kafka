#
# Cookbook Name:: kafka
# Libraries:: log4j
#

module Kafka
  module Log4J
    def render_appender(name, options)
      prefix = format('log4j.appender.%s', name)
      content = []
      options.each do |key, value|
        case key.to_sym
        when :type
          content.unshift(%(#{prefix}=#{value}))
        when :layout
          content += render_layout(prefix, value)
        else
          content << %(#{prefix}.#{camelcase(key)}=#{value.respond_to?(:call) ? value.call : value})
        end
      end
      content.join($/) << newline
    end

    def render_logger(name, options)
      level_appender = [options['level'], options['appender']].compact.join(', ')
      definition = format('log4j.logger.%s=%s', name, level_appender)
      content = [definition]
      unless (additivity = options['additivity']).nil?
        content << %(log4j.additivity.#{name}=#{additivity})
      end
      content.join($/) << newline
    end

    private

    def render_layout(prefix, options)
      layout_prefix = format('%s.layout', prefix)
      options.each_with_object([]) do |(k, v), acc|
        if k.to_sym == :type
          acc.unshift(%(#{layout_prefix}=#{v}))
        else
          acc << %(#{layout_prefix}.#{camelcase(k)}=#{v})
        end
      end
    end

    def camelcase(s)
      s.split('_').reduce('') { |a, e| a << e.capitalize }
    end

    def newline
      @newline ||= "\n".freeze
    end
  end
end
