# encoding: utf-8

require 'spec_helper'
require 'support/service_common'

describe 'service for sysv init style' do
  include_context 'service setup'

  let :start_command_string do
    'service kafka start'
  end

  let :stop_command_string do
    'service kafka stop'
  end

  let :status_command_string do
    'service kafka status'
  end

  let :pidfile do
    file '/var/run/kafka.pid'
  end

  describe 'service kafka start' do
    context 'when Kafka isn\'t already running' do
      before do
        start_command
      end

      it 'prints a message about starting Kafka' do
        expect(start_command.stdout).to match /starting.+kafka/i
        expect(start_command.stderr).to be_empty
      end

      it 'exists with status 0' do
        expect(start_command.exit_status).to be_zero
      end

      it 'starts Kafka' do
        expect(kafka_service).to be_running
      end

      it 'creates a pid file' do
        pid_file = file('/var/run/kafka.pid')
        expect(pid_file).to be_a_file
        expect(pid_file.content).to_not be_empty
      end

      it 'sets configured `ulimit` value' do
        pid = file('/var/run/kafka.pid').content.strip
        limits = file("/proc/#{pid}/limits").content
        expect(limits).to match(/Max open files\s+128000\s+128000\s+files/)
      end

      include_examples 'a Kafka start command'
    end

    context 'when Kafka is already running' do
      before do
        start_kafka(true)
      end

      it 'is actually running' do
        expect(kafka_service).to be_running
      end

      it 'prints a message about starting Kafka' do
        expect(start_command.stdout).to match /starting.+kafka/i
        expect(start_command.stderr).to be_empty
      end

      it 'exits with status 0' do
        expect(start_command.exit_status).to be_zero
      end

      it 'does not start a new process' do
        first_pid = file('/var/run/kafka.pid').content.strip
        start_kafka
        new_pid = file('/var/run/kafka.pid').content.strip
        expect(first_pid).to eq(new_pid)
      end
    end
  end

  describe 'service kafka stop' do
    context 'when Kafka is running' do
      before do
        start_command
        stop_command
      end

      it 'prints a message about stopping Kafka' do
        expect(stop_command.stdout).to match /stopping.+kafka/i
        expect(stop_command.stderr).to be_empty
      end

      it 'exits with status 0' do
        expect(stop_command.exit_status).to be_zero
      end

      it 'stops Kafka' do
        expect(kafka_service).to_not be_running
      end

      it 'removes the pid file' do
        expect(pidfile).to_not be_a_file
      end

      include_examples 'a Kafka stop command'
    end

    context 'when Kafka is not running' do
      before do
        stop_kafka
      end

      it 'prints a message about stopping kafka' do
        command = stop_kafka
        expect(command.stdout).to match /stopping.+kafka/i
        expect(command.stderr).to be_empty
      end

      it 'exits with status 0' do
        expect(stop_kafka.exit_status).to be_zero
      end
    end
  end

  describe 'service kafka status' do
    let :message do
      status_command.stdout
    end

    context 'when Kafka is running' do
      before do
        start_command
      end

      it 'exits with status 0' do
        expect(status_command.exit_status).to be_zero
      end

      it 'prints a message that Kafka is running' do
        if fedora?
          expect(message).to match /Active: active \(running\)/
          expect(message).to match /Started SYSV: kafka daemon/
        else
          expect(message).to match /kafka.+running/i
        end
        expect(status_command.stderr).to be_empty
      end
    end

    context 'when Kafka isn\'t running' do
      before do
        stop_kafka
      end

      it 'exits with status 3' do
        expect(status_command.exit_status).to eq 3
      end

      it 'prints a message that Kafka is not running / stopped' do
        if debian? || ubuntu?
          expect(message).to match /kafka is not running/i
        elsif fedora?
          expect(message).to match /Active: failed/i
          expect(message).to match /Stopped SYSV: kafka daemon/i
        else
          expect(message).to match /kafka is stopped/i
        end
        expect(status_command.stderr).to be_empty
      end
    end
  end
end
