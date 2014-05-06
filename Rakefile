# encoding: utf-8

require 'rspec/core/rake_task'
require 'tmpdir'

RSpec::Core::RakeTask.new(:spec)

desc 'Package the latest version as a .tar.gz archive'
task :package do # => :spec do
  contents = Dir.glob('*')
  contents.reject! { |path| path.start_with?('.') }
  contents.reject! { |path| %w(test spec).include?(path) }
  contents.select! { |path| File.directory?(path) }
  contents << 'metadata.rb'
  contents << 'README.md'

  version = %x(git tag -l | tail -1).strip
  release_name = %(kafka-cookbook-#{version})
  archive = %(#{release_name}.tar.gz)
  current_directory = File.expand_path('..', __FILE__)

  unless File.exist?(archive)
    Dir.mktmpdir do |sandbox_path|
      File.join(sandbox_path, release_name).tap do |cbk|
        Dir.mkdir(cbk)
        FileUtils.cp_r(contents, cbk)
      end

      Dir.chdir(sandbox_path) do
        %x(tar -czf #{archive} #{release_name})
        FileUtils.mv(archive, current_directory)
      end
    end

    puts %(Created archive of #{version} as #{archive})
  else
    puts %(#{archive} already exist, ignoring...)
    exit(1)
  end
end