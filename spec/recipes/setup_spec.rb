# encoding: utf-8

require 'spec_helper'

describe 'kafka::_setup' do
  let :chef_run do
    ChefSpec::Runner.new do |node|
      node.set[:kafka] = kafka_attrs
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
        expect(chef_run).to create_user('kafka').with({
          shell: '/sbin/nologin',
          gid: 'kafka'
        })
      end
    end

    context 'when disabled' do
      let :kafka_attrs do
        {manage_user: false}
      end

      it 'does not create a kafka group' do
        expect(chef_run).not_to create_group('kafka')
      end

      it 'does not create a kafka user' do
        expect(chef_run).not_to create_user('kafka').with({
          shell: '/sbin/nologin',
          gid: 'kafka'
        })
      end
    end

    context 'when overridden' do
      let :kafka_attrs do
        {user: 'spec', group: 'spec'}
      end

      it 'creates a group with set name' do
        expect(chef_run).to create_group('spec')
      end

      it 'creates a user with set name' do
        expect(chef_run).to create_user('spec').with({
          shell: '/sbin/nologin',
          gid: 'spec'
        })
      end
    end
  end

  it 'creates installation directory' do
    expect(chef_run).to create_directory('/opt/kafka-0.8.1.1').with({
      owner: 'kafka',
      group: 'kafka',
      mode: '755'
    })
  end

  it 'creates build directory' do
    expect(chef_run).to create_directory(%(#{Dir.tmpdir}/kafka-build)).with({
      owner: 'kafka',
      group: 'kafka',
      mode: '755'
    })
  end

  it 'creates log directory' do
    expect(chef_run).to create_directory('/var/log/kafka').with({
      owner: 'kafka',
      group: 'kafka',
      mode: '755'
    })
  end

  it 'creates scripts directory' do
    expect(chef_run).to create_directory('/usr/libexec/kafka').with(mode: '755')
  end

  it 'creates utility scripts' do
    %w[post-start stop].each do |script|
      expect(chef_run).to create_cookbook_file(::File.join('/usr/libexec/kafka', script)).with(mode: '755')
    end
  end

  context 'log dirs for Kafka data' do
    shared_examples_for 'construction of log dirs' do
      it 'creates a directory for each path in `log.dirs`' do
        %w[/mnt/kafka-1 /mnt/kafka-2].each do |path|
          expect(chef_run).to create_directory(path).with({
            owner: 'kafka',
            group: 'kafka',
            mode: '755',
            recursive: true,
          })
        end
      end
    end

    context 'when using `underscore` notation' do
      let :kafka_attrs do
        {
          broker: {
            log_dirs: %w[/mnt/kafka-1 /mnt/kafka-2]
          }
        }
      end

      include_examples 'construction of log dirs'
    end

    context 'when using `nested hash` notation' do
      let :kafka_attrs do
        {
          broker: {
            log: {
              dirs: %w[/mnt/kafka-1 /mnt/kafka-2]
            }
          }
        }
      end

      include_examples 'construction of log dirs'
    end

    context 'when using String keys' do
      let :kafka_attrs do
        {
          broker: {
            'log.dirs' => %w[/mnt/kafka-1 /mnt/kafka-2]
          }
        }
      end

      include_examples 'construction of log dirs'
    end
  end
end
