# encoding: utf-8

require 'chefspec'
require 'chefspec/berkshelf'

require 'chef/application'

RSpec.configure do |config|
  # Set to :fatal to avoid warnings about resource cloning
  config.log_level = :fatal

  # Default platform used
  config.platform = 'centos'

  # Default platform version
  config.version = '6.4'
end
