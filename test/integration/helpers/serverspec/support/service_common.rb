# encoding: utf-8

shared_context 'service setup' do
  let :kafka_service do
    service 'kafka'
  end

  let :start_command do
    run_command start_command_string
  end

  let :stop_command do
    run_command stop_command_string
  end

  let :status_command do
    run_command status_command_string
  end

  before :all do
    run_command %(su -s /bin/bash kafka -c '/opt/kafka/bin/zookeeper-server-start.sh -daemon /opt/kafka/config/zookeeper.properties')
  end

  after :all do
    run_command %(ps ax | grep -i 'zookeeper' | grep -v grep | awk '{print $1}' | xargs kill -SIGKILL)
  end

  after do
    run_command stop_command_string
    Dir['/var/log/kafka/kafka*'].each do |path|
      FileUtils.remove_entry_secure(path)
    end
  end
end

shared_examples_for 'a Kafka start command' do
  describe '/var/log/kafka/kafka.log' do
    let :log_file do
      file '/var/log/kafka/kafka.log'
    end

    it 'exists' do
      expect(log_file).to be_a_file
    end

    it 'contains a log message about start up' do
      expect(log_file.content).to match /(Kafka Server .+ starting|starting .+KafkaServer)/i
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

shared_examples_for 'a Kafka stop command' do
  describe '/var/log/kafka/kafka.log' do
    let :log_file do
      file '/var/log/kafka/kafka.log'
    end

    it 'exists' do
      expect(log_file).to be_a_file
    end

    it 'logs that shut down is completed' do
      expect(log_file.content).to match /Kafka Server .+ (Shut down completed|shutting down)/i
    end
  end
end
