# encoding: utf-8

module AwaitHelpers
  def await(max_time = 30)
    started_at = Time.now
    until yield
      sleep 1
      raise 'Wait timed out!' if (Time.now - started_at) > max_time
    end
  end
end

RSpec.configure do |config|
  config.include(AwaitHelpers)
end
