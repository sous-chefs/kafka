# encoding: utf-8

require 'spec_helper'

describe 'kafka::binary' do
  describe file('/opt/kafka/dist') do
    it { should be_a_directory }
    it { should be_mode 755 }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
  end

  describe file('/tmp/kitchen/cache/kafka_2.8.0-0.8.0.tar.gz') do
    it { should be_a_file }
    it { should be_mode 644 }
    it { should match_md5checksum '593e0cf966e6b8cd1bbff5bff713c4b3' }
  end

  describe file('/opt/kafka/kafka_2.8.0-0.8.0.jar') do
    it { should be_a_file }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
  end

  describe 'service kafka start' do
    context 'when kafka is already running' do
      before do
        backend.run_command 'service kafka start'
      end

      it 'is actually running' do
        expect(service 'kafka').to be_running
      end

      describe command 'service kafka start' do
        it { should return_exit_status 0 }
        it { should return_stdout /kafka .+ already running/ }
      end
    end

    context 'when kafka is not already running' do
      before do
        backend.run_command 'service kafka stop'
      end

      it 'is not currently running' do
        expect(service 'kafka').not_to be_running
      end

      describe command 'service kafka start' do
        it { should return_stdout /Starting kafka/ }
        it { should return_exit_status 0 }

        it 'actually starts kafka' do
          backend.run_command 'service kafka start'

          expect(service 'kafka').to be_running
        end
      end
    end
  end

  describe 'service kafka stop' do
    context 'when kafka is running' do
      before do
        backend.run_command 'service kafka start'
      end

      it 'is actually running' do
        expect(service 'kafka').to be_running
      end

      describe command 'service kafka stop' do
        it { should return_exit_status 0 }
        it { should return_stdout /Stopping kafka/ }

        it 'actually stops kafka' do
          backend.run_command 'service kafka stop'

          expect(service 'kafka').not_to be_running
        end
      end
    end

    context 'when kafka is not running' do
      before do
        backend.run_command 'service kafka stop'
      end

      it 'is not currently running' do
        expect(service 'kafka').not_to be_running
      end

      describe command 'service kafka stop' do
        it { should return_stdout /Stopping kafka/ }
        it { should return_exit_status 0 }
      end
    end
  end
end
