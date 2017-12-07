# encoding: utf-8

require 'spec_helper'

describe 'kafka::_setup' do
  let :chef_run do
    ChefSpec::SoloRunner.new do |node|
      node.override['kafka'] = kafka_attrs
    end.converge('kafka::_defaults', described_recipe)
  end

  let :kafka_attrs do
    {}
  end

  context 'group and user' do
    context 'by default' do
      it 'creates a kafka group' do
        expect(chef_run).to create_group('kafka')
      end

      it 'creates a kafka user' do
        expect(chef_run).to create_user('kafka').with(
          shell: '/sbin/nologin',
          group: 'kafka',
        )
      end
    end

    context 'when uid and gid are set' do
      let :kafka_attrs do
        { uid: 1234, gid: 5678 }
      end

      it 'creates a kafka group with the specified ID' do
        expect(chef_run).to create_group('kafka').with(gid: 5678)
      end

      it 'creates a kafka user with the specified ID' do
        expect(chef_run).to create_user('kafka').with(
          shell: '/sbin/nologin',
          group: 'kafka',
          uid: 1234,
        )
      end
    end

    context 'when disabled' do
      let :kafka_attrs do
        { 'manage_user' => false }
      end

      it 'does not create a kafka group' do
        expect(chef_run).not_to create_group('kafka')
      end

      it 'does not create a kafka user' do
        expect(chef_run).not_to create_user('kafka').with(
          shell: '/sbin/nologin',
          gid: 'kafka',
        )
      end
    end

    context 'when overridden' do
      let :kafka_attrs do
        { 'user' => 'spec', 'group' => 'spec' }
      end

      it 'creates a group with set name' do
        expect(chef_run).to create_group('spec')
      end

      it 'creates a user with set name' do
        expect(chef_run).to create_user('spec').with_shell('/sbin/nologin')
      end
    end
  end

  it 'creates installation directory' do
    expect(chef_run).to create_directory('/opt/kafka-1.0.0').with(
      owner: 'kafka',
      group: 'kafka',
      mode: '755',
    )
  end

  it 'creates build directory' do
    expect(chef_run).to create_directory(File.join(Dir.tmpdir, 'kafka-build')).with(
      owner: 'kafka',
      group: 'kafka',
      mode: '755',
    )
  end

  it 'creates log directory' do
    expect(chef_run).to create_directory('/var/log/kafka').with(
      owner: 'kafka',
      group: 'kafka',
      mode: '755',
    )
  end

  context 'log dirs for Kafka data' do
    let :kafka_attrs do
      {
        'broker' => {
          'log.dirs' => %w[/mnt/kafka-1 /mnt/kafka-2],
        },
      }
    end

    it 'creates a directory for each path in `log.dirs`' do
      %w[/mnt/kafka-1 /mnt/kafka-2].each do |path|
        expect(chef_run).to create_directory(path).with(
          owner: 'kafka',
          group: 'kafka',
          mode: '755',
          recursive: true,
        )
      end
    end
  end
end
