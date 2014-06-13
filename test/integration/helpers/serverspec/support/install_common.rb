# encoding: utf-8

require 'support/configuration_common'

shared_examples_for 'an install method' do
  it_behaves_like 'a _setup recipe'
  it_behaves_like 'a _configure recipe'

  context 'directories in install directory' do
    describe '/opt/kafka/libs' do
      it_behaves_like 'a kafka directory' do
        let :path do
          '/opt/kafka/libs'
        end
      end
    end

    describe '/opt/kafka/bin' do
      let :path do
        '/opt/kafka/bin'
      end

      let :files do
        Dir[File.join(path, '*')]
      end

      it_behaves_like 'a kafka directory'

      it 'contains kafka-run-class.sh' do
        expect(files.grep(/kafka-run-class\.sh$/)).to_not be_empty
      end

      describe '/opt/kafka/bin/kafka-run-class.sh' do
        it_behaves_like 'an executable kafka file' do
          let :path do
            '/opt/kafka/bin/kafka-run-class.sh'
          end
        end
      end
    end
  end
end
