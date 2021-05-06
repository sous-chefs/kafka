require 'spec_helper'

describe 'kafka::default' do
  describe group('kafka') do
    it { should exist }
    it { should have_gid(5678) }
  end

  describe user('kafka') do
    it { should exist }
    it { should have_uid(1234) }
    it { should belong_to_group('kafka') }
    it { should have_login_shell('/sbin/nologin') }
    it { should have_home_directory('/var/empty/kafka') }

    describe file('/home/kafka') do
      it { should_not be_a_file }
      it { should_not be_a_directory }
    end
  end

  describe file('/opt/kafka') do
    it { should be_a_directory }
  end

  describe '/opt/kafka/config' do
    include_examples 'a kafka directory' do
      let :path do
        '/opt/kafka/config'
      end
    end
  end

  describe '/var/log/kafka' do
    include_examples 'a kafka directory', skip_files: true do
      let :path do
        '/var/log/kafka'
      end
    end
  end

  context 'configured `log.dirs`' do
    %w(/mnt/kafka-logs-1 /mnt/kafka-logs-2).each do |directory|
      describe directory do
        include_examples 'a kafka directory', skip_files: true do
          let :path do
            directory
          end
        end
      end
    end
  end

  describe '/opt/kafka/config/log4j.properties' do
    include_examples 'a non-executable kafka file' do
      let :path do
        '/opt/kafka/config/log4j.properties'
      end
    end
    describe file('/opt/kafka/config/log4j.properties') do
      let(:path) { '/sbin:/usr/local/sbin:$PATH' }
      its('content') { should match %r{log4j.appender.kafkaAppender.File=/var/log/kafka/kafka.log\nlog4j.appender.kafkaAppender.layout=org.apache.log4j.PatternLayout} }
    end
  end

  describe '/opt/kafka/config/server.properties' do
    include_examples 'a non-executable kafka file' do
      let :path do
        '/opt/kafka/config/server.properties'
      end
    end
  end

  context 'directories in install directory' do
    describe '/opt/kafka/libs' do
      include_examples 'a kafka directory' do
        let :path do
          '/opt/kafka/libs'
        end
      end
    end

    describe '/opt/kafka/bin' do
      let :path do
        '/opt/kafka/bin'
      end

      let :files do
        Dir[File.join(path, '*')]
      end

      include_examples 'a kafka directory'

      it 'contains kafka-run-class.sh' do
        expect(files.grep(/kafka-run-class\.sh$/)).to_not be_empty
      end

      describe '/opt/kafka/bin/kafka-run-class.sh' do
        include_examples 'an executable kafka file' do
          let :path do
            '/opt/kafka/bin/kafka-run-class.sh'
          end
        end
      end
    end
  end
end
