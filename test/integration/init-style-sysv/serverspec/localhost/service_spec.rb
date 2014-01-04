# encoding: utf-8

require 'spec_helper'

describe 'service for sysv init style' do
  let :kafka_service do
    service 'kafka'
  end

  let :start_command do
    command 'service kafka start'
  end

  let :stop_command do
    command 'service kafka stop'
  end

  let :status_command do
    command 'service kafka status'
  end

  shared_examples_for 'a kafka start command' do
    describe '/var/log/kafka/kafka.log' do
      let :log_file do
        file '/var/log/kafka/kafka.log'
      end

      it 'exists' do
        expect(log_file).to be_a_file
      end

      it 'contains a log message about start up' do
        expect(log_file.content).to match /Kafka Server .+ Starting/
      end

      it 'contains a log message about awaiting connections' do
        expect(log_file.content).to match /Awaiting socket connections/
      end

      it 'contains a log message that the broker has started' do
        expect(log_file.content).to match /Socket Server on Broker .+ Started/
      end
    end

    describe '/var/log/kafka/kafka-gc.log' do
      let :log_file do
        file '/var/log/kafka/kafka-gc.log'
      end

      it 'exists' do
        expect(log_file).to be_a_file
      end
    end
  end

  shared_examples_for 'a kafka stop command' do
    let :log_file do
      file '/var/log/kafka/kafka.log'
    end

    describe '/var/log/kafka/kafka.log' do
      it 'exists' do
        expect(log_file).to be_a_file
      end

      it 'logs that shut down is completed' do
        expect(log_file.content).to match /Kafka Server .+ Shut down completed/
      end
    end
  end

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
        if debian?
          expect(status_command).to return_stdout /kafka is not running/
        elsif fedora?
          expect(status_command).to return_stdout /Active: failed/
        else
          expect(status_command).to return_stdout /kafka is stopped/
        end
      end
    end
  end
end
