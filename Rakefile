# encoding: utf-8

require 'rspec/core/rake_task'
require 'tmpdir'

RSpec::Core::RakeTask.new(:spec)

desc 'Package the latest version as a .tar.gz archive'
task :package => :spec do
  contents = Dir.glob('*')
  contents.reject! { |path| path.start_with?('.') }
  contents.reject! { |path| %w(test spec gemfiles pkg).include?(path) }
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
    puts %(#{archive} already exist, exiting...)
    exit(1)
  end
end

desc 'Test all v0.8.x versions'
namespace :test do
  task :docker do
    docker_vm_running = %x{boot2docker status} && $?.success?

    unless docker_vm_running
      %x{boot2docker up}
    end

    versions = %w[0.8.0 0.8.1 0.8.1.1]
    versions.each do |version|
      envs = []
      envs << %(KITCHEN_LOCAL_YAML=.kitchen.docker.yml)
      envs << %(KAFKA_VERSION=#{version})
      envs << %(SCALA_VERSION=2.8.0) if version == '0.8.0'
      envs = envs.join(' ')

      rd, wr = IO.pipe
      pid = Process.fork do
        $stdout.reopen(wr)
        rd.close
        exec(%(#{envs} bundle exec kitchen test))
      end
      wr.close
      rd.each do |line|
        puts line
      end
      _, status = Process.waitpid2(pid)
      break unless status.success?
    end
  end
end