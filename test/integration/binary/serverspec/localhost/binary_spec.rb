# encoding: utf-8

require 'spec_helper'

describe 'kafka::binary' do
  describe 'downloaded release' do
    let :downloaded_release do
      file('/tmp/kitchen/cache/kafka_2.8.0-0.8.0.tar.gz')
    end

    it 'exists' do
      expect(downloaded_release).to be_a_file
    end

    it 'has 644 permissions' do
      expect(downloaded_release).to be_mode 644
    end

    it 'matches md5 checksum' do
      expect(downloaded_release).to match_md5checksum '593e0cf966e6b8cd1bbff5bff713c4b3'
    end
  end

  describe 'extracted jar' do
    let :extracted_jar do
      file('/opt/kafka/kafka_2.8.0-0.8.0.jar')
    end

    it 'exists' do
      expect(extracted_jar).to be_a_file
    end

    it 'is owned by kafka' do
      expect(extracted_jar).to be_owned_by 'kafka'
    end

    it 'belongs to kafka group' do
      expect(extracted_jar).to be_grouped_into 'kafka'
    end
  end

  shared_examples_for 'a directory in /opt/kafka' do
    let :kafka_directory do
      file path
    end

    it 'exists' do
      expect(kafka_directory).to be_a_directory
    end

    it 'has 755 permissions' do
      expect(kafka_directory).to be_mode 755
    end

    it 'is owned by kafka' do
      expect(kafka_directory).to be_owned_by 'kafka'
    end

    it 'belongs to kafka group' do
      expect(kafka_directory).to be_grouped_into 'kafka'
    end

    it 'is not empty' do
      expect(Dir[File.join(path, '*')]).not_to be_empty
    end
  end

  describe '/opt/kafka/dist' do
    let :path do
      '/opt/kafka/dist'
    end

    it_behaves_like 'a directory in /opt/kafka'
  end

  describe '/opt/kafka/libs' do
    let :path do
      '/opt/kafka/libs'
    end

    it_behaves_like 'a directory in /opt/kafka'
  end

  describe '/opt/kafka/bin' do
    let :path do
      '/opt/kafka/bin'
    end

    let :files do
      Dir[File.join(path, '*')]
    end

    it_behaves_like 'a directory in /opt/kafka'

    it 'contains kafka-run-class.sh' do
      expect(files.grep(/kafka-run-class\.sh$/)).to be_true
    end

    describe 'kafka-run-class.sh' do
      let :run_class do
        file '/opt/kafka/bin/kafka-run-class.sh'
      end

      it 'is a file' do
        expect(run_class).to be_a_file
      end

      it 'is owned by kafka' do
        expect(run_class).to be_owned_by 'kafka'
      end

      it 'belongs to kafka group' do
        expect(run_class).to be_grouped_into 'kafka'
      end

      it 'is executable by kafka' do
        expect(run_class).to be_executable.by_user('kafka')
      end

      it 'is executable by root' do
        expect(run_class).to be_executable.by_user('root')
      end
    end
  end
end
