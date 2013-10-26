# encoding: utf-8

require 'spec_helper'

describe 'kafka::binary' do
  describe file('/opt/kafka/dist') do
    it { should be_a_directory }
    it { should be_mode 755 }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
  end

  describe file('/tmp/kitchen-chef-solo/cache/kafka_2.8.0-0.8.0-beta1.tgz') do
    it { should be_a_file }
    it { should be_mode 644 }
    it { should match_md5checksum 'f12e7698aff37a0e014cb9dc087f0b8f' }
  end

  describe file('/opt/kafka/kafka_2.8.0-0.8.0-beta1.jar') do
    it { should be_a_file }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
  end
end
