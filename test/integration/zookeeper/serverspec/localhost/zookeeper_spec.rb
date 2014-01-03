# encoding: utf-8

require 'spec_helper'

describe 'kafka::zookeeper' do
  describe file('/opt/kafka/config/zookeeper.properties') do
    it { should be_a_file }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 644 }
  end

  describe file('/opt/kafka/config/log4j.properties') do
    it { should be_a_file }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 644 }
  end

  describe file('/var/log/zookeeper') do
    it { should be_a_directory }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 755 }
  end

  describe service('zookeeper') do
    it { should be_running }
  end
end
