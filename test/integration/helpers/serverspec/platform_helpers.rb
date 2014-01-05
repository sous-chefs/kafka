# encoding: utf-8

module PlatformHelpers
  def debian?
    family == 'debian'
  end

  def centos?
    family == 'redhat' && %w(5.9 6.4 6.5).include?(release)
  end

  def fedora?
    family == 'redhat' && %w(18 19 20).include?(release)
  end

  private

  def family
    RSpec.configuration.os[:family].downcase
  end

  def release
    RSpec.configuration.os[:release]
  end
end
