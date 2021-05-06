require 'spec_helper'

describe 'required files for systemd init style' do
  describe 'environment file' do
    let :env_file do
      file(debian? || ubuntu? ? '/etc/default/kafka' : '/etc/sysconfig/kafka')
    end

    it 'exists' do
      expect(env_file).to be_a_file
    end

    it 'is owned by root' do
      expect(env_file).to be_owned_by 'root'
    end

    it 'belongs to the root group' do
      expect(env_file).to be_grouped_into 'root'
    end

    it 'has 644 permissions' do
      expect(env_file).to be_mode 644
    end

    it 'is properly formatted with newlines' do
      expect(env_file.content).to match(%r{SCALA_VERSION=.*\nKAFKA_OPTS=.*\nJMX_PORT=.*})
    end
  end

  describe 'init configuration' do
    let :init_file do
      file '/etc/systemd/system/kafka.service'
    end

    it 'exists' do
      expect(init_file).to be_a_file
    end

    it 'is owned by root' do
      expect(init_file).to be_owned_by 'root'
    end

    it 'belongs to the root group' do
      expect(init_file).to be_grouped_into 'root'
    end

    it 'has 644 permissions' do
      expect(init_file).to be_mode 644
    end
  end
end
