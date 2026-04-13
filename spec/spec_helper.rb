# frozen_string_literal: true

require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
  config.file_cache_path = '/var/cache/chef'
  config.log_level = :error
  config.platform = 'ubuntu'
  config.version = '24.04'
end
