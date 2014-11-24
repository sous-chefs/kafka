# encoding: utf-8

require 'spec_helper'
require 'support/service_common'

describe 'service for systemd init style' do
  include_context 'service setup' do
    let :start_command do
      command 'systemctl start kafka.service'
    end

    let :stop_command do
      command 'systemctl stop kafka.service'
    end

    let :status_command do
      command 'systemctl status kafka.service'
    end
  end

  describe 'service kafka start' do
    context 'when kafka is not already running' do
      before do
        backend.run_command 'systemctl stop kafka.service 2> /dev/null || true'
      end

      it 'is not already running' do
        expect(kafka_service).not_to be_running
      end

      it 'does not print anything' do
        expect(start_command).to return_stdout ''
      end

      it 'exits with status 0' do
        expect(start_command).to return_exit_status 0
      end

      it 'actually starts kafka' do
        backend.run_command 'systemctl start kafka.service && sleep 3'

        expect(kafka_service).to be_running
      end

      it 'sets configured `ulimit` values' do
        backend.run_command 'systemctl start kafka.service'
        output = status_command.stdout
        pid = output[/Main PID: (\d+)/, 1].strip
        limits = file("/proc/#{pid}/limits").content
        expect(limits).to match(/Max open files\s+128000\s+128000\s+files/)
      end

      it_behaves_like 'a kafka start command'
    end

    context 'when kafka is already running' do
      before do
        backend.run_command 'systemctl start kafka.service 2> /dev/null || true'
      end

      it 'is actually already running' do
        expect(kafka_service).to be_running
      end

      it 'does not print anything' do
        expect(start_command).to return_stdout ''
      end

      it 'does not start a new process' do
        output = backend.run_command('systemctl status kafka.service').stdout.split("\n")
        first_pid = output.grep /Main PID/
        output = backend.run_command('systemctl status kafka.service').stdout.split("\n")
        new_pid = output.grep /Main PID/
        expect(first_pid).to eq(new_pid)
      end

      it_behaves_like 'a kafka start command'
    end
  end

  describe 'service kafka stop' do
    context 'when kafka is running' do
      before do
        backend.run_command 'systemctl start kafka.service 2> /dev/null || true'
      end

      it 'is actaully already running' do
        expect(kafka_service).to be_running
      end

      it 'prints nothing' do
        expect(stop_command).to return_stdout ''
      end

      it 'exits with status 0' do
        expect(stop_command).to return_exit_status 0
      end

      it 'actually stops kafka' do
        backend.run_command 'systemctl stop kafka.service'

        expect(kafka_service).not_to be_running
      end

      it_behaves_like 'a kafka stop command'
    end

    context 'when kafka is not running' do
      before do
        backend.run_command 'systemctl stop kafka.service 2> /dev/null || true'
      end

      it 'is not running' do
        expect(kafka_service).not_to be_running
      end

      it 'prints nothing' do
        expect(stop_command).to return_stdout ''
      end

      it 'exits with status 0' do
        expect(stop_command).to return_exit_status 0
      end

      it_behaves_like 'a kafka stop command'
    end
  end

  describe 'service kafka status' do
    context 'when kafka is running' do
      before do
        backend.run_command 'sleep 10 && systemctl restart kafka.service 2> /dev/null || true'
      end

      it 'exits with status 0' do
        expect(status_command).to return_exit_status 0
      end

      it 'prints a message that kafka is running' do
        expect(status_command).to return_stdout /Active: active \(running\)/
      end
    end

    context 'when kafka is not running' do
      before do
        backend.run_command 'systemctl stop kafka.service 2> /dev/null || true'
      end

      it 'exits with status 3' do
        expect(status_command).to return_exit_status 3
      end

      it 'prints a message that kafka is stopped' do
        expect(status_command).to return_stdout /Active: inactive \(dead\)/
      end
    end
  end
end
