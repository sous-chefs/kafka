# encoding: utf-8

require 'spec_helper'

describe 'verification of scripts' do
  shared_context 'init script setup' do
    let :script do
      c = ChefSpec::Runner.new(options).converge('kafka::default')
      t = c.template('/etc/init.d/kafka')
      r = ChefSpec::Renderer.new(c, t)
      f = Tempfile.new('kafka-init')
      f.puts(r.content)
      f.rewind
      f.close
      f
    end

    let :options do
      {}
    end

    after do
      script.unlink
    end
  end

  describe 'shellcheck /etc/init.d/kafka' do
    include_context 'init script setup'

    it 'passes' do
      expect { shellcheck(script.path, 'SC1091') }.to_not raise_error
    end
  end if shellcheck_installed?

  describe 'shellcheck /etc/init.d/kafka (debian)' do
    include_context 'init script setup'

    let :options do
      {platform: 'debian', version: '7.4'}
    end

    it 'passes' do
      expect { shellcheck(script.path, 'SC1091') }.to_not raise_error
    end
  end if shellcheck_installed?

  Dir[File.expand_path('../../../files/default/*.bash', __FILE__)].each do |full_path|
    describe sprintf('shellcheck %s', File.basename(full_path)) do
      it 'passes' do
        expect { shellcheck(full_path) }.to_not raise_error
      end
    end if shellcheck_installed?
  end
end
