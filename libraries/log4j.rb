# encoding: utf-8

module Kafka
  module Log4J
    def render_appender(name, clazz, options)
      prefix = 'log4j.appender.%s' % name
      content = ['%s=%s' % [prefix, clazz]]
      options.each do |key, value|
        if key == 'layout'
          content += render_layout(prefix, *value)
        else
          content << [%(#{prefix}.#{camelcase(key)}), value].join('=')
        end
      end
      content.join($/) << newline
    end

    def render_logger(name, root_str, options)
      content = []
      content << [['log4j.logger', name].join('.') << '=' << root_str]
      options.each do |key, value|
        if key == 'additivity'
          content << (['log4j', 'additivity', name].join('.') << '=' << value.to_s)
        end
      end
      content.join($/) << newline
    end

    private

    def render_layout(prefix, clazz, options)
      layout_prefix = '%s.layout' % prefix
      content = ['%s=%s' % [layout_prefix, clazz]]
      options.each do |key, value|
        content << [%(#{layout_prefix}.#{camelcase(key)}), value].join('=')
      end
      content
    end

    def camelcase(s)
      s.split('_').reduce('') { |acc, p| acc << p.capitalize }
    end

    def newline
      @newline ||= "\n".freeze
    end
  end
end
