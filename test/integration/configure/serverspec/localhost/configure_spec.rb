# encoding: utf-8

require 'spec_helper'

describe 'kafka::configure' do
  describe group('kafka') do
    it { should exist }
  end

  describe user('kafka') do
    it { should exist }
    it { should belong_to_group('kafka') }
    it { should have_home_directory('/home/kafka') }
    it { should have_login_shell('/bin/false') }
  end

  describe file('/opt/kafka') do
    it { should be_a_directory }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 755 }
  end

  describe file('/opt/kafka/bin') do
    it { should be_a_directory }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 755 }
  end

  describe file('/opt/kafka/config') do
    it { should be_a_directory }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 755 }
  end

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

  describe file('/opt/kafka/libs') do
    it { should be_a_directory }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 755 }
  end

  describe file('/var/log/kafka') do
    it { should be_a_directory }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 755 }
  end

  describe file('/var/kafka') do
    it { should be_a_directory }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 755 }
  end

  describe file('/etc/init.d/kafka') do
    it { should be_a_file }
    it { should be_owned_by('root') }
    it { should be_grouped_into('root') }
    it { should be_mode 755 }
  end

  describe service('kafka') do
    let(:path) { '/sbin:/usr/sbin' }
    it { should be_enabled }
  end
end
