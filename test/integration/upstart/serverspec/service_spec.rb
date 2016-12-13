# encoding: utf-8

require 'spec_helper'

describe 'service for upstart init style' do
  include_context 'service setup'

  let :start_command_string do
    'start kafka'
  end

  let :stop_command_string do
    'stop kafka'
  end

  let :status_command_string do
    'status kafka'
  end

  let :pidfile do
    file '/var/run/kafka.pid'
  end

  describe service('kafka'), pending: centos? && systemd? do
    it { should be_enabled }
  end

  describe 'service kafka start' do
    context 'when Kafka isn\'t already running' do
      before do
        start_command
      end

      it 'prints a message about starting Kafka' do
        expect(start_command.stdout).to match(/kafka start\/running, process \d+/i)
        expect(start_command.stderr).to be_empty
      end

      it 'exits with status 0' do
        expect(start_command.exit_status).to be_zero
      end

      it 'starts Kafka' do
        expect(kafka_service).to be_running
      end

      it 'sets configured `ulimit` values' do
        pid = start_command.stdout.split(' ').last.strip
        limits = file("/proc/#{pid}/limits").content
        expect(limits).to match(/Max open files\s+128000\s+128000\s+files/)
      end

      it 'runs as the configured user' do
        pid = start_command.stdout.split(' ').last.strip
        user = run_command(format('ps -p %s -o user --no-header', pid)).stdout.strip
        expect(user).to eq('kafka')
      end

      it 'runs as the configured group' do
        pid = start_command.stdout.split(' ').last.strip
        group = run_command(format('ps -p %s -o group --no-header', pid)).stdout.strip
        expect(group).to eq('kafka')
      end

      include_examples 'a Kafka start command'
    end

    context 'when Kafka is already running' do
      before do
        start_kafka(true)
      end

      it 'prints a message that Kafka is already running' do
        expect(start_command.stderr).to match(/already running: kafka/i)
        expect(start_command.stdout).to be_empty
      end

      it 'exits with status 1' do
        expect(start_command.exit_status).to eq 1
      end

      it 'does not start a new process' do
        first_pid = run_command(status_command_string).stdout.split(' ').last.strip
        start_command
        new_pid = run_command(status_command_string).stdout.split(' ').last.strip
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
        expect(stop_command.stdout).to match(/kafka stop\/waiting/i)
        expect(stop_command.stderr).to be_empty
      end

      it 'exits with status 0' do
        expect(stop_command.exit_status).to be_zero
      end

      it 'stops Kafka' do
        expect(kafka_service).to_not be_running
        # expect(status_command.stdout).to match /kafka stop\/waiting/i
      end

      include_examples 'a Kafka stop command'
    end

    context 'when Kafka is not running' do
      it 'prints a message that Kafka is stopped' do
        command = stop_kafka
        expect(command.stderr).to match(/stop: Unknown instance:/i)
        expect(command.stdout).to be_empty
      end

      it 'exits with status 1' do
        expect(stop_kafka.exit_status).to eq 1
      end
    end
  end

  describe 'service kafka status' do
    context 'when Kafka is running' do
      before do
        start_command
      end

      it 'exits with status 0' do
        expect(status_command.exit_status).to be_zero
      end

      it 'prints a message that Kafka is running' do
        expect(status_command.stdout).to match(/kafka start\/running, process \d+/i)
        expect(status_command.stderr).to be_empty
      end
    end

    context 'when Kafka is not running' do
      it 'exits with status 0' do
        expect(status_command.exit_status).to be_zero
      end

      it 'prints a message that Kafka is stopped' do
        expect(status_command.stdout).to match(/kafka stop\/waiting/i)
        expect(status_command.stderr).to be_empty
      end
    end
  end
end
