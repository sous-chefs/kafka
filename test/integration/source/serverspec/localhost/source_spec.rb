# encoding: utf-8

require 'spec_helper'

describe 'kafka::source' do
  describe file('/opt/kafka/build') do
    it { should be_a_directory }
    it { should be_mode 755 }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
  end

  describe file('/tmp/kitchen/cache/kafka-0.8.0-src.tgz') do
    it { should be_a_file }
    it { should be_mode 644 }
    it { should match_md5checksum '46b3e65e38f1bde4b6251ea131d905f4' }
  end

  describe file('/opt/kafka/kafka_2.9.2-0.8.0.jar') do
    it { should be_a_file }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
  end

  shared_examples_for 'kafka start command' do
    describe command('service kafka start') do
      it { should return_exit_status 0 }
    end

    describe file('/var/log/kafka/kafka.log') do
      it { should be_a_file }
      its(:content) { should match /Kafka Server .+ Starting/ }
      its(:content) { should match /Awaiting socket connections/ }
      its(:content) { should match /Socket Server on Broker .+ Started/ }
    end
  end

  shared_examples_for 'kafka stop command' do
    describe command('service kafka stop') do
      it { should return_exit_status 0 }
      it { should return_stdout /stopping.+kafka/i }
    end

    describe file('/var/log/kafka/kafka.log') do
      it { should be_a_file }
      its(:content) { should match /Kafka Server .+ Shut down completed/ }
    end
  end

  describe 'service kafka start' do
    context 'when kafka is already running' do
      let :pre_command do
        'service kafka start'
      end

      describe service('kafka') do
        it { should be_running }
      end

      describe command('service kafka start') do
        case RSpec.configuration.os[:family]
        when 'Debian'
          it { should return_stdout /starting.+kafka/i }
        else
          it { should return_stdout /kafka .+ already running/ }
        end
      end

      include_examples 'kafka start command'
    end

    context 'when kafka is not already running' do
      let :pre_command do
        'service kafka stop'
      end

      describe command('service kafka start') do
        it { should return_stdout /starting.+kafka/i }
      end

      describe service('kafka') do
        let :pre_command do
          'service kafka start'
        end

        it { should be_running }
      end

      include_examples 'kafka start command'
    end
  end

  describe 'service kafka stop' do
    context 'when kafka is running' do
      let(:pre_command) { 'service kafka start' }

      describe service('kafka') do
        let(:pre_command) { 'service kafka stop' }

        it { should_not be_running }
      end

      include_examples 'kafka stop command'
    end

    context 'when kafka is not running' do
      let :pre_command do
        'service kafka stop'
      end

      describe service('kafka') do
        it { should_not be_running }
      end

      include_examples 'kafka stop command'
    end
  end

  describe 'service kafka status' do
    context 'when kafka is running' do
      let(:pre_command) { 'service kafka restart' }

      describe command('service kafka status') do
        it { should return_exit_status 0 }
        it { should return_stdout /kafka.+running/i }
      end
    end

    context 'when kafka is not running' do
      let(:pre_command) { 'service kafka stop' }

      describe command('service kafka status') do
        it { should return_exit_status 3 }

        case RSpec.configuration.os[:family]
        when 'Debian'
          it { should return_stdout /kafka is not running/ }
        else
          it { should return_stdout /kafka is stopped/ }
        end
      end
    end
  end
end
