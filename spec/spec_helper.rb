# encoding: utf-8

require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/application'


ChefSpec::Coverage.start!

RSpec.configure do |config|
  config.platform = 'centos'
  config.version = '6.4'
end

require 'support/matchers'
