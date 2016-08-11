# encoding: utf-8

require 'serverspec'

require 'support/await_helper'
require 'support/files_common'
require 'support/platform_helpers'
require 'support/service_common'

RSpec.configure do |config|
  config.backend = :exec
  config.fail_fast = true
  config.order = :random
end
