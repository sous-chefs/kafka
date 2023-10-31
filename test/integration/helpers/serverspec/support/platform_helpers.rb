module PlatformHelpers
  def debian?
    family == 'debian'
  end

  def ubuntu?
    family == 'ubuntu'
  end

  def centos?
    family == 'redhat' && %w(5.9 6.4 6.5).include?(release)
  end

  def fedora?
    family == 'fedora'
  end

  def systemd?
    family == 'fedora' || family == 'redhat7'
  end

  def run_command(cmd)
    Specinfra.backend.run_command(cmd)
  end

  private

  def family
    os[:family]
  end

  def release
    os[:release]
  end
end

RSpec.configure do |config|
  config.include(PlatformHelpers)
  config.extend(PlatformHelpers)
end
