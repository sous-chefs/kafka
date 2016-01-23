# encoding: utf-8

require 'serverspec'
require 'pathname'

require 'support/platform_helpers'
require 'support/await_helper'

RSpec.configure do |config|
  config.backend = :exec
  config.fail_fast = true
  config.order = :random
  config.include(PlatformHelpers)
  config.extend(PlatformHelpers)
end
