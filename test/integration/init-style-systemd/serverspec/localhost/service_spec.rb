# encoding: utf-8

require 'spec_helper'
require 'support/service_common'

describe 'service for systemd init style' do
  include_context 'service setup'

  let :start_command_string do
    'systemctl start kafka.service'
  end

  let :stop_command_string do
    'systemctl stop kafka.service'
  end

  let :status_command_string do
    'systemctl status kafka.service'
  end

  before :all do
    run_command 'systemctl daemon-reload'
  end

  before do
    run_command 'systemctl reset-failed kafka.service'
  end

  describe 'service kafka start' do
    context 'when Kafka isn\'t already running' do
      before do
        start_command
      end

      it 'does not print anything' do
        expect(start_command.stdout).to be_empty
        expect(start_command.stderr).to be_empty
      end

      it 'exits with status 0' do
        expect(start_command.exit_status).to be_zero
      end

      it 'starts Kafka' do
        expect(kafka_service).to be_running
      end

      it 'sets configured `ulimit` values' do
        pid = status_command.stdout[/Main PID: (\d+)/, 1].strip
        limits = file("/proc/#{pid}/limits").content
        expect(limits).to match /Max open files\s+128000\s+128000\s+files/i
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

      it 'does not print anything' do
        expect(start_command.stdout).to be_empty
        expect(start_command.stderr).to be_empty
      end

      it 'exits with status 0' do
        expect(start_command.exit_status).to be_zero
      end

      it 'does not start a new process' do
        first_pid = run_command(status_command_string).stdout.split("\n").grep /Main PID/
        start_kafka
        new_pid = run_command(status_command_string).stdout.split("\n").grep /Main PID/
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

      it 'does not print anything' do
        expect(stop_command.stdout).to be_empty
        expect(stop_command.stderr).to be_empty
      end

      it 'exits with status 0' do
        expect(stop_command.exit_status).to be_zero
      end

      it 'stops Kafka' do
        expect(kafka_service).not_to be_running
      end

      include_examples 'a Kafka stop command'
    end

    context 'when Kafka is not running' do
      before do
        stop_kafka
      end

      it 'prints nothing' do
        command = stop_kafka
        expect(command.stdout).to be_empty
        expect(command.stderr).to be_empty
      end

      it 'exits with status 0' do
        expect(stop_kafka.exit_status).to be_zero
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
        expect(status_command.stdout).to match /Active: active \(running\)/i
        expect(status_command.stderr).to be_empty
      end
    end

    context 'when Kafka is not running' do
      before do
        stop_kafka
      end

      it 'exits with status 3' do
        expect(status_command.exit_status).to eq 3
      end

      it 'prints a message that Kafka is stopped' do
        expect(status_command.stdout).to match /Active: inactive \(dead\)/i
        expect(status_command.stderr).to be_empty
      end
    end
  end
end
