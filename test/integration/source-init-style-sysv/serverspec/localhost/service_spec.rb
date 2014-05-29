# encoding: utf-8

require 'spec_helper'
require 'support/service_common'

describe 'service for sysv init style' do
  include_context 'service setup'

  describe 'service kafka start' do
    context 'when kafka is not already running' do
      before do
        backend.run_command 'service kafka stop 2> /dev/null || true'
      end

      it 'is not actually running' do
        expect(kafka_service).not_to be_running
      end

      it 'prints a message about starting kafka' do
        expect(start_command).to return_stdout /starting.+kafka/i
      end

      it 'exits with status 0' do
        expect(start_command).to return_exit_status 0
      end

      it 'actually starts kafka' do
        backend.run_command 'service kafka start'

        expect(kafka_service).to be_running
      end

      it_behaves_like 'a kafka start command'
    end

    context 'when kafka is already running' do
      before do
        backend.run_command 'service kafka start 2> /dev/null || true'
      end

      it 'is actually running' do
        expect(kafka_service).to be_running
      end

      it 'prints a message about starting kafka' do
        expect(start_command).to return_stdout /starting.+kafka/i
      end

      it 'exits with status 0' do
        expect(start_command).to return_exit_status 0
      end

      it_behaves_like 'a kafka start command'
    end
  end

  describe 'service kafka stop' do
    context 'when kafka is running' do
      before do
        backend.run_command 'service kafka start 2> /dev/null || true'
      end

      it 'is actually running' do
        expect(kafka_service).to be_running
      end

      it 'prints a message about stopping kafka' do
        expect(stop_command).to return_stdout /stopping.+kafka/i
      end

      it 'exits with status 0' do
        expect(stop_command).to return_exit_status 0
      end

      it 'stops kafka' do
        backend.run_command 'service kafka stop'

        expect(kafka_service).not_to be_running
      end

      it_behaves_like 'a kafka stop command'
    end

    context 'when kafka is not running' do
      before do
        backend.run_command 'service kafka stop 2> /dev/null || true'
      end

      it 'is actually not running' do
        expect(kafka_service).not_to be_running
      end

      it 'prints a message about stopping kafka' do
        expect(stop_command).to return_stdout /stopping.+kafka/i
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
        backend.run_command 'service kafka start 2> /dev/null || true'
      end

      it 'exits with status 0' do
        expect(status_command).to return_exit_status 0
      end

      it 'prints a message that kafka is running' do
        if fedora?
          expect(status_command).to return_stdout /Active: active \(running\)/
          expect(status_command).to return_stdout /Started SYSV: kafka daemon/
        else
          expect(status_command).to return_stdout /kafka.+running/i
        end
      end
    end

    context 'when kafka is not running' do
      before do
        backend.run_command 'service kafka stop 2> /dev/null || true'
      end

      it 'exits with status 3' do
        expect(status_command).to return_exit_status 3
      end

      it 'prints a message that kafka is not running / stopped' do
        if debian? || ubuntu?
          expect(status_command).to return_stdout /kafka is not running/
        elsif fedora?
          expect(status_command).to return_stdout /Active: failed/
          expect(status_command).to return_stdout /Stopped SYSV: kafka daemon/
        else
          expect(status_command).to return_stdout /kafka is stopped/
        end
      end
    end
  end
end
