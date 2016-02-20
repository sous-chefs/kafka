# encoding: utf-8

shared_context 'service setup' do
  let :kafka_service do
    service 'kafka'
  end

  let :start_command do
    start_kafka(true)
  end

  let :stop_command do
    stop_kafka(true)
  end

  let :log_file_path do
    '/var/log/kafka/kafka.log'
  end

  let :log_file do
    file(log_file_path)
  end

  let :status_command do
    run_command status_command_string
  end

  let :start_regexp do
    /kafka server .+ started/i
  end

  let :stop_regexp do
    /kafka server .+ shut down completed/i
  end

  before :all do
    @pid = Process.fork do
      exec('su -s /bin/bash kafka -c "/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties"')
    end
  end

  after :all do
    run_command %(ps ax | grep -i 'zookeeper' | grep -v grep | awk '{print $1}' | xargs kill -SIGKILL)
    Process.wait(@pid)
  end

  after do
    stop_kafka
    Dir['/var/log/kafka/kafka*'].each do |path|
      FileUtils.remove_entry_secure(path)
    end
  end

  def start_kafka(wait=false)
    result = run_command(start_command_string)
    if wait && result.exit_status.zero?
      await(10) do
        File.exists?(log_file_path) && File.read(log_file_path).match(start_regexp)
      end
    end
    result
  end

  def stop_kafka(wait=false)
    result = run_command(stop_command_string)
    if wait && result.exit_status.zero?
      await(10) { File.exists?(log_file_path) && File.read(log_file_path).match(stop_regexp) }
    end
    result
  end
end

shared_examples_for 'a Kafka start command' do
  describe '/var/log/kafka/kafka.log' do
    it 'exists' do
      expect(log_file).to be_a_file
    end

    it 'contains a log message about start up' do
      expect(log_file.content).to match start_regexp
    end
  end

  describe '/var/log/kafka/kafka-gc.log' do
    let :gc_log_file do
      file '/var/log/kafka/kafka-gc.log'
    end

    it 'exists' do
      expect(gc_log_file).to be_a_file
    end
  end
end

shared_examples_for 'a Kafka stop command' do
  describe '/var/log/kafka/kafka.log' do
    it 'exists' do
      expect(log_file).to be_a_file
    end

    it 'contains a log message that shut down is completed' do
      expect(log_file.content).to match stop_regexp
    end
  end
end
