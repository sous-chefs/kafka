# encoding: utf-8

require 'rspec/expectations'

RSpec::Matchers.define :have_configured do |configuration_file|
  match do |chef_run|
    regexp_str = %(^#{Regexp.quote(@attribute)})
    regexp_str << %(=#{Regexp.quote(@value)}$) if @value
    regexp = Regexp.new(regexp_str)
    @matcher = ChefSpec::Matchers::RenderFileMatcher.new(configuration_file)
    @matcher.with_content(regexp).matches?(chef_run)
  end

  if respond_to?(:failure_message)
    failure_message { @matcher.failure_message }
  elsif respond_to?(:failure_message_for_should)
    failure_message_for_should { @matcher.failure_message_for_should }
  end

  chain :as do |value|
    @value = value.to_s
  end

  chain :with do |attribute|
    @attribute = attribute
  end
end
