# encoding: utf-8

require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.before(:each) do
    stub_command("update-alternatives --display java | grep '/usr/lib/jvm/jre-1.6.0-openjdk.x86_64/bin/java - priority 1061'").and_return(true)
  end
end
