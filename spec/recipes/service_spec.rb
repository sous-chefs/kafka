# encoding: utf-8

require 'spec_helper'

describe 'kafka service' do
  let :chef_run do
    ChefSpec::SoloRunner.new do |node|
      node.set['kafka'] = { 'init_style' => init_style }.merge(kafka_attributes)
    end.converge(*described_recipes)
  end

  let :described_recipes do
    ['kafka::_defaults', 'kafka::_configure', 'kafka::_service', 'kafka::_coordinate']
  end

  let :kafka_attributes do
    {}
  end

  let :init_style do
    :sysv
  end

  shared_examples_for 'a service setup' do
    it 'enables a `kafka` service' do
      expect(service.action).to include(:enable)
    end

    context 'automatic_restart attribute' do
      let :config_paths do
        paths = %w[/opt/kafka/config/server.properties /opt/kafka/config/log4j.properties]
        if init_style != :runit
          paths << '/etc/sysconfig/kafka'
          paths << '/etc/init.d/kafka'
        end
        paths
      end

      let :config_templates do
        config_paths.map do |config_path|
          chef_run.template(config_path) || chef_run.file(config_path)
        end
      end

      context 'by default' do
        it 'does not restart kafka on configuration changes' do
          config_templates.each do |template|
            expect(template).not_to notify('ruby_block[coordinate-kafka-start]').to(:create)
          end
        end
      end

      context 'when set to true' do
        let :kafka_attributes do
          { 'automatic_restart' => true }
        end

        it 'restarts kafka when configuration is changed' do
          config_templates.each do |template|
            expect(template).to notify('ruby_block[coordinate-kafka-start]').to(:create)
          end
        end

        it 'starts kafka' do
          expect(service.action).to include(:start)
        end
      end
    end

    context 'automatic_start attribute' do
      context 'by default' do
        it 'does not start kafka' do
          expect(service.action).to_not include(:start)
        end
      end

      context 'when set to true' do
        let :kafka_attributes do
          { 'automatic_start' => true }
        end

        it 'starts kafka' do
          expect(service.action).to include(:start)
        end
      end
    end
  end

  context 'when init_style is :runit' do
    let :init_style do
      :runit
    end

    let :service do
      chef_run.runit_service('kafka')
    end

    before do
      described_recipes.delete('kafka::_service')
      described_recipes.unshift('runit::default')
    end

    include_examples 'a service setup'

    context 'coordination recipe' do
      it 'includes a recipe for coordinating starts / restarts' do
        expect(chef_run).to include_recipe('kafka::_coordinate')
      end

      it 'creates the correct service resource' do
        expect(chef_run).to_not start_runit_service('kafka')
      end

      it 'notifies the correct service resource to restart' do
        expect(chef_run.ruby_block('coordinate-kafka-start')).to notify('runit_service[kafka]').to(:restart)
        expect(chef_run.ruby_block('coordinate-kafka-start')).not_to notify('service[kafka]').to(:restart)
      end

      it 'doesn\'t actually do anything by default' do
        expect(chef_run.ruby_block('coordinate-kafka-start')).to do_nothing
      end
    end
  end

  context 'when any other init_style' do
    let :service do
      chef_run.service('kafka')
    end

    include_examples 'a service setup'

    context 'coordination recipe' do
      it 'includes a recipe for coordinating starts / restarts' do
        expect(chef_run).to include_recipe('kafka::_coordinate')
      end

      it 'creates the correct service resource' do
        expect(chef_run).to_not start_service('kafka')
      end

      it 'notifies the correct service resource to restart' do
        expect(chef_run.ruby_block('coordinate-kafka-start')).to notify('service[kafka]').to(:restart)
        expect(chef_run.ruby_block('coordinate-kafka-start')).not_to notify('runit_service[kafka]').to(:restart)
      end

      it 'doesn\'t actually do anything by default' do
        expect(chef_run.ruby_block('coordinate-kafka-start')).to do_nothing
      end
    end
  end
end
