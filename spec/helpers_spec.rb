# frozen_string_literal: true

require 'spec_helper'
require_relative '../libraries/helpers'

describe Kafka::Helpers do
  subject(:helper) do
    Class.new do
      include Kafka::Helpers
    end.new
  end

  let(:resource) do
    Struct.new(
      :version,
      :scala_version,
      :base_url,
      :version_install_dir,
      :install_dir,
      :broker_config,
      :log_dir,
      :jmx_port,
      :log4j_opts,
      :heap_opts,
      :gc_log_opts,
      :generic_opts,
      :jvm_performance_opts,
      :jmx_opts,
      :user,
      :group,
      :env_path,
      :config_dir,
      :kill_timeout,
      :ulimit_file
    ).new(
      '4.2.0',
      '2.13',
      'https://downloads.apache.org/kafka',
      '/opt/kafka-4.2.0',
      '/opt/kafka',
      { 'log.dirs' => '/var/lib/kafka/a,/var/lib/kafka/b' },
      '/var/log/kafka',
      9999,
      '-Dlog4j.configuration=file:/opt/kafka/config/log4j.properties',
      '-Xmx1G -Xms1G',
      nil,
      nil,
      '-server',
      '-Dcom.sun.management.jmxremote',
      'kafka',
      'kafka',
      '/etc/default/kafka',
      '/opt/kafka/config',
      10,
      128000
    )
  end

  it 'builds archive names and URLs' do
    expect(helper.kafka_archive_name(resource)).to eq('kafka_2.13-4.2.0.tgz')
    expect(helper.kafka_download_url(resource)).to eq('https://downloads.apache.org/kafka/4.2.0/kafka_2.13-4.2.0.tgz')
  end

  it 'normalizes checksum strings' do
    expect(helper.kafka_normalize_checksum('AA BB cc')).to eq('aabbcc')
  end

  it 'splits broker log directories' do
    expect(helper.kafka_log_dirs(resource)).to eq(%w(/var/lib/kafka/a /var/lib/kafka/b))
  end

  it 'renders environment content' do
    expect(helper.kafka_env_content(resource)).to include('KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"')
  end

  it 'builds systemd content' do
    expect(helper.kafka_systemd_content(resource)['Service']['ExecStart']).to eq('/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties')
    expect(helper.kafka_systemd_content(resource)['Service']['LimitNOFILE']).to eq('128000')
  end
end
