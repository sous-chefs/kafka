# encoding: utf-8

shared_context 'service setup' do
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
      expect(log_file.content).to match /Kafka Server .+ Starting/i
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
      expect(log_file.content).to match /Kafka Server .+ Shut down completed/i
    end
  end
end
