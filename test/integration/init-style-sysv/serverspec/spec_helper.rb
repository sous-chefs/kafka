# encoding: utf-8

require 'serverspec'
require 'pathname'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

module PlatformHelpers
  def debian?
    family == 'debian'
  end

  def centos?
    family == 'redhat' && %w(5.9 6.4 6.5).include?(release)
  end

  private

  def family
    RSpec.configuration.os[:family].downcase
  end

  def release
    RSpec.configuration.os[:release]
  end
end

RSpec.configure do |config|
  config.os = backend.check_os
  config.include(PlatformHelpers)
  config.extend(PlatformHelpers)
end
