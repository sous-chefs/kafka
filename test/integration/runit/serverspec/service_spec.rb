# encoding: utf-8

require 'spec_helper'

describe 'service for runit init style' do
  include_context 'service setup'

  let :start_command_string do
    'sv start kafka'
  end

  let :stop_command_string do
    'sv stop kafka'
  end

  let :status_command_string do
    'sv status kafka'
  end

  def fetch_pid
    run_command('cat /etc/sv/kafka/supervise/pid')
  end

  describe 'service kafka start' do
    context 'when Kafka isn\'t already running' do
      before do
        start_command
      end

      it 'prints a message about starting Kafka' do
        expect(start_command.stdout).to match(/ok: run: kafka: \(pid \d+\) \d+s/)
        expect(start_command.stderr).to be_empty
      end

      it 'exists with status 0' do
        expect(start_command.exit_status).to be_zero
      end

      it 'starts Kafka' do
        expect(kafka_service).to be_running.under('runit')
      end

      it 'sets configured `ulimit` value' do
        pid = fetch_pid.stdout.strip
        limits = file("/proc/#{pid}/limits").content
        expect(limits).to match(/Max open files\s+128000\s+128000\s+files/)
      end

      it 'runs as the configured user' do
        pid = fetch_pid.stdout.strip
        user = run_command(format('ps -p %s -o user --no-header', pid)).stdout.strip
        expect(user).to eq('kafka')
      end

      it 'runs as the configured group' do
        pid = fetch_pid.stdout.strip
        group = run_command(format('ps -p %s -o group --no-header', pid)).stdout.strip
        expect(group).to eq('kafka')
      end

      include_examples 'a Kafka start command'
    end

    context 'when Kafka is already running' do
      before do
        start_kafka(true)
      end

      it 'is actually running' do
        expect(kafka_service).to be_running.under('runit')
      end

      it 'prints a message about starting Kafka' do
        expect(start_command.stdout).to match(/ok: run: kafka: \(pid \d+\) \d+s/)
        expect(start_command.stderr).to be_empty
      end

      it 'exits with status 0' do
        expect(start_command.exit_status).to be_zero
      end

      it 'does not start a new process' do
        first_pid = fetch_pid.stdout.strip
        start_command
        new_pid = fetch_pid.stdout.strip
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
        expect(stop_command.stdout).to match(/ok: down: kafka: \d+s/)
        expect(stop_command.stderr).to be_empty
      end

      it 'exits with status 0' do
        expect(stop_command.exit_status).to be_zero
      end

      it 'stops Kafka' do
        expect(kafka_service).not_to be_running.under('runit')
      end

      include_examples 'a Kafka stop command'
    end

    context 'when Kafka is not running' do
      before do
        stop_kafka
      end

      it 'prints a message about stopping kafka' do
        command = stop_kafka
        expect(command.stdout).to match(/ok: down: kafka: \d+s/)
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
        expect(message).to match(/run: kafka: \(pid \d+\) \d+s/)
        expect(status_command.stderr).to be_empty
      end
    end

    context 'when Kafka isn\'t running' do
      before do
        stop_kafka
      end

      it 'exits with status 0' do
        expect(status_command.exit_status).to eq 0
      end

      it 'prints a message that Kafka is not running / stopped' do
        expect(message).to match(/down: kafka: \d+s/)
        expect(status_command.stderr).to be_empty
      end
    end
  end
end
