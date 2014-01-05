# encoding: utf-8

require 'files_common'

shared_examples_for 'a _setup recipe' do
  describe group('kafka') do
    it { should exist }
  end

  describe user('kafka') do
    it { should exist }
    it { should belong_to_group('kafka') }
    it { should have_login_shell('/sbin/nologin') }
  end

  describe '/opt/kafka' do
    it_behaves_like 'a kafka directory', skip_files: true do
      let :path do
        '/opt/kafka'
      end
    end
  end

  describe '/opt/kafka/config' do
    it_behaves_like 'a kafka directory' do
      let :path do
        '/opt/kafka/config'
      end
    end
  end

  describe '/var/log/kafka' do
    it_behaves_like 'a kafka directory', skip_files: true do
      let :path do
        '/var/log/kafka'
      end
    end
  end
end

shared_examples_for 'a _configure recipe' do
  describe '/opt/kafka/config/log4j.properties' do
    it_behaves_like 'a non-executable kafka file' do
      let :path do
        '/opt/kafka/config/log4j.properties'
      end
    end
  end

  describe '/opt/kafka/config/server.properties' do
    it_behaves_like 'a non-executable kafka file' do
      let :path do
        '/opt/kafka/config/server.properties'
      end
    end
  end

  describe service('kafka') do
    it { should be_enabled }
  end
end
