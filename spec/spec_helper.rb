# encoding: utf-8

require 'chefspec'
require 'chefspec/berkshelf'

require 'chef/application'

RSpec.configure do |config|
  # Default platform used
  config.platform = 'centos'

  # Default platform version
  config.version = '6.4'
end

require 'support/matchers'

at_exit { ChefSpec::Coverage.report! }
