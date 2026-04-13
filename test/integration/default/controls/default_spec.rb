# frozen_string_literal: true

title 'Default Suite Tests'

control 'kafka-install-01' do
  impact 1.0
  title 'Kafka user and group exist'

  describe group('kafka') do
    it { should exist }
    its('gid') { should eq 5678 }
  end

  describe user('kafka') do
    it { should exist }
    its('uid') { should eq 1234 }
    its('group') { should eq 'kafka' }
    its('home') { should eq '/var/empty/kafka' }
    its('shell') { should eq '/sbin/nologin' }
  end
end

control 'kafka-install-02' do
  impact 1.0
  title 'Kafka installation and data directories exist'

  describe file('/opt/kafka') do
    it { should be_symlink }
    its('link_path') { should eq '/opt/kafka-3.9.1' }
  end

  %w(/opt/kafka-3.9.1 /opt/kafka/config /var/log/kafka /var/lib/kafka/data).each do |path|
    describe directory(path) do
      it { should exist }
      its('owner') { should eq 'kafka' }
      its('group') { should eq 'kafka' }
    end
  end
end

control 'kafka-config-01' do
  impact 1.0
  title 'Kafka config files exist and contain KRaft settings'

  describe file('/opt/kafka/config/server.properties') do
    it { should exist }
    its('mode') { should cmp '0600' }
    its('content') { should match(/process\.roles=broker,controller/) }
    its('content') { should match(/controller\.quorum\.voters=1@127\.0\.0\.1:9093/) }
    its('content') { should match(%r{log\.dirs=/var/lib/kafka/data}) }
  end

  describe file('/opt/kafka/config/log4j.properties') do
    it { should exist }
    its('mode') { should cmp '0644' }
    its('content') { should match(/log4j\.rootLogger=INFO, kafkaAppender/) }
  end

  describe file('/etc/default/kafka') do
    it { should exist }
    its('content') { should match(/KAFKA_HEAP_OPTS="-Xms1G -Xmx1G"/) }
    its('content') { should match(/KAFKA_JMX_OPTS="-Dcom\.sun\.management\.jmxremote/) }
  end
end

control 'kafka-service-01' do
  impact 1.0
  title 'Kafka systemd service is installed and running'

  describe systemd_service('kafka') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/systemd/system/kafka.service') do
    it { should exist }
    its('content') { should match(%r{ExecStart=/opt/kafka/bin/kafka-server-start\.sh /opt/kafka/config/server\.properties}) }
    its('content') { should match(/User=kafka/) }
    its('content') { should match(/Group=kafka/) }
    its('content') { should match(/LimitNOFILE=128000/) }
  end

  describe port(9092) do
    it { should be_listening }
  end

  describe file('/var/lib/kafka/data/meta.properties') do
    it { should exist }
    its('content') { should match(/cluster\.id=/) }
  end
end
