# encoding: utf-8

require 'spec_helper'

describe 'required files for sysv init style' do
  describe 'environment file' do
    let :env_file do
      file path
    end

    let :path do
      if debian? || ubuntu?
        '/etc/default/kafka'
      else
        '/etc/sysconfig/kafka'
      end
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
  end

  describe 'init script' do
    let :init_file do
      file '/etc/init.d/kafka'
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

    it 'has 755 permissions' do
      expect(init_file).to be_mode 755
    end
  end
end
