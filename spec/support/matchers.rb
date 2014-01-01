# encoding: utf-8

RSpec::Matchers.define :have_configured do |configuration_file|
  match do |chef_run|
    regexp = Regexp.new("^#{Regexp.quote(@attribute)}=#{@value}$")
    render_file(configuration_file).with_content(regexp).matches?(chef_run)
  end

  failure_message_for_should do |actual|
    "expected that #{configuration_file} would be configured with #{@attribute} as #{@value}"
  end

  chain :as do |value|
    @value = value
  end

  chain :with do |attribute|
    @attribute = attribute
  end
end
