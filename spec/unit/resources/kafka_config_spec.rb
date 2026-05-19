# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_config' do
  step_into :kafka_config
  platform 'ubuntu', '24.04'

  context 'with broker config' do
    recipe do
      kafka_config 'default' do
        broker_config(
          'process.roles' => 'broker,controller',
          'node.id' => 1
        )
      end
    end

    it { is_expected.to create_directory('/opt/kafka/config') }
    it { is_expected.to create_directory('/var/log/kafka') }
    it { is_expected.to create_file('/etc/default/kafka').with(content: /KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"/) }
    it { is_expected.to create_template('/opt/kafka/config/log4j.properties') }
    it { is_expected.to create_template('/opt/kafka/config/server.properties') }
    it { is_expected.to render_file('/opt/kafka/config/server.properties').with_content(/process\.roles=broker,controller/) }
    it { is_expected.to render_file('/opt/kafka/config/server.properties').with_content(/node\.id=1/) }
  end

  context 'action :delete' do
    recipe do
      kafka_config 'default' do
        action :delete
      end
    end

    it { is_expected.to delete_file('/etc/default/kafka') }
    it { is_expected.to delete_directory('/opt/kafka/config') }
  end
end
