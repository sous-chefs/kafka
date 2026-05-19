# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_service' do
  step_into :kafka_service
  platform 'ubuntu', '24.04'

  context 'action :create' do
    recipe do
      kafka_service 'default'
    end

    it { is_expected.to create_systemd_unit('kafka.service') }
    it { is_expected.to enable_systemd_unit('kafka.service') }
  end

  context 'action :start' do
    recipe do
      kafka_service 'default' do
        action :start
      end
    end

    it { is_expected.to start_systemd_unit('kafka.service') }
  end

  context 'action :delete' do
    recipe do
      kafka_service 'default' do
        action :delete
      end
    end

    it { is_expected.to stop_systemd_unit('kafka.service') }
    it { is_expected.to disable_systemd_unit('kafka.service') }
    it { is_expected.to delete_systemd_unit('kafka.service') }
  end
end
