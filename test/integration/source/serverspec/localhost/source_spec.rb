# encoding: utf-8

require 'spec_helper'

describe 'kafka::source' do
  describe 'downloaded source' do
    let :downloaded_source do
      file('/tmp/kitchen/cache/kafka-0.8.0-src.tgz')
    end

    it 'exists' do
      expect(downloaded_source).to be_a_file
    end

    it 'has 644 permissions' do
      expect(downloaded_source).to be_mode 644
    end

    it 'matches md5 checksum' do
      expect(downloaded_source).to match_md5checksum '46b3e65e38f1bde4b6251ea131d905f4'
    end
  end

  describe 'extracted jar' do
    let :extracted_jar do
      file('/opt/kafka/kafka_2.9.2-0.8.0.jar')
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

  describe '/opt/kafka/build' do
    let :path do
      '/opt/kafka/build'
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

      it 'has 755 permissions' do
        expect(run_class).to be_mode 755
      end
    end
  end
end
