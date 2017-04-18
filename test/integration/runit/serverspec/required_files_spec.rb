# encoding: utf-8

require 'spec_helper'

describe 'required files for runit init style' do
  describe 'environment files' do
    let :env_dir do
      file path
    end

    let :path do
      '/etc/service/kafka/env'
    end

    it 'exists' do
      expect(env_dir).to be_a_directory
    end

    it 'is owned by root' do
      expect(env_dir).to be_owned_by 'root'
    end

    it 'belongs to the root group' do
      expect(env_dir).to be_grouped_into 'root'
    end

    it 'has 755 permissions' do
      expect(env_dir).to be_mode 755
    end

    it 'is not empty' do
      expect(Dir[File.join(path, '*')]).to_not be_empty
    end
  end

  describe 'run script' do
    let :init_file do
      file '/etc/service/kafka/run'
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
