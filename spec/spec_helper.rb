# encoding: utf-8

require 'chef/application'

require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.log_level = :fatal
end
