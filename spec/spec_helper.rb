# encoding: utf-8

require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/application'
require 'support/matchers'
require 'support/shellcheck'


ChefSpec::Coverage.start!

RSpec.configure do |config|
  config.platform = 'centos'
  config.version = '6.4'
  config.alias_it_should_behave_like_to :it_behaves_correctly, 'behaves correctly'
  config.include Shellcheck
  config.extend Shellcheck
end
