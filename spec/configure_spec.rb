# encoding: utf-8

require 'spec_helper'

describe 'kafka::configure' do
  let :chef_run do
    ChefSpec::Runner.new(platform: 'centos', version: '6.4').converge(described_recipe)
  end

  it 'includes java::default recipe' do
    expect(chef_run).to include_recipe('java::default')
  end

  context 'group and user' do
    context 'by default' do
      it 'creates a kafka group' do
        expect(chef_run).to create_group('kafka')
      end

      it 'creates a kafka user' do
        expect(chef_run).to create_user('kafka')

        user = chef_run.user('kafka')
        expect(user.shell).to eq('/bin/false')
        expect(user.home).to eq('/home/kafka')
        expect(user.gid).to eq('kafka')
      end
    end

    context 'when overridden' do
      let :chef_run do
        ChefSpec::Runner.new(platform: 'centos', version: '6.4') do |node|
          node.set[:kafka][:user] = 'spec'
          node.set[:kafka][:group] = 'spec'
        end.converge(described_recipe)
      end

      it 'creates a group with set name' do
        expect(chef_run).to create_user('spec')
      end

      it 'creates a user with set name' do
        expect(chef_run).to create_user('spec')

        user = chef_run.user('spec')
        expect(user.shell).to eq('/bin/false')
        expect(user.home).to eq('/home/spec')
        expect(user.gid).to eq('spec')
      end
    end
  end

  it 'creates installation directory' do
    expect(chef_run).to create_directory('/opt/kafka')

    directory = chef_run.directory('/opt/kafka')
    expect(directory.owner).to eq('kafka')
    expect(directory.group).to eq('kafka')
    expect(directory.mode).to eq('755')
  end

  it 'creates \'bin\' directory in installation directory' do
    expect(chef_run).to create_directory('/opt/kafka/bin')

    directory = chef_run.directory('/opt/kafka/bin')
    expect(directory.owner).to eq('kafka')
    expect(directory.group).to eq('kafka')
    expect(directory.mode).to eq('755')
  end

  it 'creates \'config\' directory in installation directory' do
    expect(chef_run).to create_directory('/opt/kafka/config')

    directory = chef_run.directory('/opt/kafka/config')
    expect(directory.owner).to eq('kafka')
    expect(directory.group).to eq('kafka')
    expect(directory.mode).to eq('755')
  end

  it 'creates \'libs\' directory in installation directory' do
    expect(chef_run).to create_directory('/opt/kafka/libs')

    directory = chef_run.directory('/opt/kafka/libs')
    expect(directory.owner).to eq('kafka')
    expect(directory.group).to eq('kafka')
    expect(directory.mode).to eq('755')
  end

  it 'creates log directory' do
    expect(chef_run).to create_directory('/var/log/kafka')

    directory = chef_run.directory('/var/log/kafka')
    expect(directory.owner).to eq('kafka')
    expect(directory.group).to eq('kafka')
    expect(directory.mode).to eq('755')
  end

  it 'creates data directory' do
    expect(chef_run).to create_directory('/var/kafka')

    directory = chef_run.directory('/var/kafka')
    expect(directory.owner).to eq('kafka')
    expect(directory.group).to eq('kafka')
    expect(directory.mode).to eq('755')
  end

  it 'creates an init.d script' do
    expect(chef_run).to create_template('/etc/init.d/kafka')

    file = chef_run.template('/etc/init.d/kafka')
    expect(file.owner).to eq('root')
    expect(file.group).to eq('root')
    expect(file.mode).to eq('755')
  end

  it 'creates a kafka service' do
    service = chef_run.service('kafka')

    expect(service.action).to eq([:enable])
  end
end
