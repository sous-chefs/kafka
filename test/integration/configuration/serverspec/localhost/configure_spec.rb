# encoding: utf-8

require 'spec_helper'

describe 'kafka::configure' do
  describe file('/opt/kafka/config/log4j.properties') do
    it { should be_a_file }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 644 }
  end

  describe file('/opt/kafka/config/server.properties') do
    it { should be_a_file }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 644 }
  end

  describe service('kafka') do
    it { should be_enabled }
  end
end
