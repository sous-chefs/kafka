# frozen_string_literal: true

title 'Kafka default resource'

control 'kafka-user-01' do
  impact 1.0
  title 'Kafka user and group exist'

  describe group('kafka') do
    it { should exist }
    its('gid') { should cmp 5678 }
  end

  describe user('kafka') do
    it { should exist }
    its('uid') { should cmp 1234 }
    its('group') { should eq 'kafka' }
  end
end

control 'kafka-files-01' do
  impact 1.0
  title 'Kafka directories and configuration are present'

  describe file('/opt/kafka') do
    it { should be_symlink }
    its('link_path') { should eq '/opt/kafka-4.2.0' }
  end

  %w(
    /opt/kafka-4.2.0
    /opt/kafka/config
    /var/log/kafka
    /var/lib/kafka/data
  ).each do |dir|
    describe directory(dir) do
      it { should exist }
      its('owner') { should eq 'kafka' }
      its('group') { should eq 'kafka' }
    end
  end

  describe file('/opt/kafka/config/server.properties') do
    it { should exist }
    its('mode') { should cmp '0600' }
    its('owner') { should eq 'kafka' }
    its('group') { should eq 'kafka' }
    its('content') { should match(/process\.roles=broker,controller/) }
    its('content') { should match(/controller\.quorum\.voters=1@localhost:9093/) }
  end

  env_path = os.debian? ? '/etc/default/kafka' : '/etc/sysconfig/kafka'

  describe file(env_path) do
    it { should exist }
    its('content') { should match(/KAFKA_HEAP_OPTS="-Xmx256M -Xms256M"/) }
  end
end

control 'kafka-service-01' do
  impact 1.0
  title 'Kafka service is enabled and running'

  describe systemd_service('kafka') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe command('systemctl show kafka --property MainPID --value') do
    its('stdout.strip') { should_not eq '0' }
    its('stdout.strip') { should match(/^\d+$/) }
  end
end
