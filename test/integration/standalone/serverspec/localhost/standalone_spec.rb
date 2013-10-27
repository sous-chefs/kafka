# encoding: utf-8

require 'spec_helper'

describe 'kafka::standalone' do
  describe file('/opt/kafka/config/zookeeper.properties') do
    it { should be_a_file }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 644 }
  end

  describe file('/opt/kafka/config/zookeeper.log4j.properties') do
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

  describe file('/etc/init.d/zookeeper') do
    it { should be_a_file }
    it { should be_owned_by('root') }
    it { should be_grouped_into('root') }
    it { should be_mode 755 }
  end

  describe service('zookeeper') do
    let(:path) { '/sbin:/usr/sbin' }
    it { should be_enabled }
    it { should be_running }
  end

  describe service('kafka') do
    let(:path) { '/sbin:/usr/sbin' }
    it { should be_enabled }
    it { should be_running }
  end
end
