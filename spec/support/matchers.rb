# encoding: utf-8

RSpec::Matchers.define :have_configured do |configuration_file|
  match do |chef_run|
    regexp = Regexp.new("^#{Regexp.quote(@attribute)}=#{Regexp.quote(@value)}$")
    @matcher = ChefSpec::Matchers::RenderFileMatcher.new(configuration_file)
    @matcher.with_content(regexp).matches?(chef_run)
  end

  failure_message_for_should do |actual|
    @matcher.failure_message_for_should
  end

  chain :as do |value|
    @value = value.to_s
  end

  chain :with do |attribute|
    @attribute = attribute
  end
end
