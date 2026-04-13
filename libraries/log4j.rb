# frozen_string_literal: true

module KafkaCookbook
  module Log4J
    def render_appender(name, options)
      prefix = "log4j.appender.#{name}"
      content = []

      options.each do |key, value|
        case key.to_s
        when 'type'
          content.unshift("#{prefix}=#{value}")
        when 'layout'
          content.concat(render_layout(prefix, value))
        else
          content << "#{prefix}.#{camelcase(key)}=#{value}"
        end
      end

      content.join("\n") << "\n"
    end

    def render_logger(name, options)
      definition = "log4j.logger.#{name}=#{[options['level'], options['appender']].compact.join(', ')}"
      content = [definition]
      content << "log4j.additivity.#{name}=#{options['additivity']}" unless options['additivity'].nil?
      content.join("\n") << "\n"
    end

    private

    def render_layout(prefix, options)
      layout_prefix = "#{prefix}.layout"

      options.each_with_object([]) do |(key, value), rendered|
        if key.to_s == 'type'
          rendered.unshift("#{layout_prefix}=#{value}")
        else
          rendered << "#{layout_prefix}.#{camelcase(key)}=#{value}"
        end
      end
    end

    def camelcase(value)
      value.to_s.split('_').map(&:capitalize).join
    end
  end
end
