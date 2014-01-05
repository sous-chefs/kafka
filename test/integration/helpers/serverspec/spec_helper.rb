# encoding: utf-8

require 'serverspec'
require 'pathname'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

require 'platform_helpers'

RSpec.configure do |config|
  config.os = backend.check_os
  config.include(PlatformHelpers)
  config.extend(PlatformHelpers)
end
