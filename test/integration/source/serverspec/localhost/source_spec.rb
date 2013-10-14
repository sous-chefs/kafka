# encoding: utf-8

require 'spec_helper'

describe 'kafka::source' do
  describe file('/opt/kafka/build') do
    it { should be_a_directory }
    it { should be_mode 755 }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
  end

  describe file('/tmp/kitchen-chef-solo/cache/kafka-0.8.0-beta1-src.tgz') do
    it { should be_a_file }
    it { should be_mode 644 }
    it { should match_md5checksum 'b90e355ea2bc1e5f62db1836fdd77502' }
  end

  describe file('/opt/kafka/kafka_2.9.2-0.8.0-beta1.jar') do
    it { should be_a_file }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
  end
end
