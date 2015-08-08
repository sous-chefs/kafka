# encoding: utf-8

require 'rspec/core/rake_task'
require 'foodcritic'
require 'tmpdir'

RSpec::Core::RakeTask.new(:spec)
FoodCritic::Rake::LintTask.new

desc 'Run FoodCritic and ChefSpec'
task :test do
  Rake::Task['foodcritic'].execute
  Rake::Task['spec'].execute
end

desc 'Package the latest version as a .tar.gz archive'
task :package => :spec do
  contents = Dir.glob('*')
  contents.reject! { |path| path.start_with?('.') }
  contents.reject! { |path| %w[test spec gemfiles pkg].include?(path) }
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

class DockerTask

  attr_reader :output, :duration

  def initialize(version)
    @version = version
    @output = []
    @env = {}
    @concurrency = ENV.fetch('concurrency', 3).to_i
  end

  def run
    start_timestamp = Time.now
    @env['KITCHEN_LOCAL_YAML'] = '.kitchen.docker.yml'
    @env['KAFKA_VERSION'] = @version
    @env['SCALA_VERSION'] = '2.8.0' if @version == '0.8.0'
    rd, wr = IO.pipe
    pid = Process.fork do
      $stdout.reopen(wr)
      rd.close
      exec(@env, 'bundle exec kitchen test --concurrency=%d' % [@concurrency])
    end
    wr.close
    rd.each do |line|
      @output << line
    end
    _, status = Process.waitpid2(pid)
    @duration = Time.now - start_timestamp
    status
  end
end

namespace :test do
  default_versions = %w[0.8.0 0.8.1 0.8.1.1 0.8.2.0 0.8.2.1]

  def run_tests_for(versions)
    puts '>>> Running tests for versions: %s' % [versions.join(', ')]
    failed_versions = []
    versions.each do |version|
      puts '>>> Starting tests for v%s' % version
      task = DockerTask.new(version)
      if task.run.success?
        puts '>>> Done testing v%s, run took %d seconds' % [version, task.duration]
      else
        puts task.output
        puts '>>> v%s failed, run took %d seconds, see output above ^' % [version, task.duration]
        print '>>> Continue with the remaining versions? [Y/n]: '
        answer = $stdin.gets.strip.downcase
        if answer.empty? || answer == 'y'
          failed_versions << version
          next
        else
          break
        end
      end
    end
    failed_versions
  end

  desc 'Run test-kitchen with kitchen-docker'
  task :docker => 'docker:running' do
    versions = ENV.fetch('versions', default_versions.join(',')).split(',')
    done = false
    until done do
      failed_versions = run_tests_for(versions)
      if failed_versions.any?
        print '>>> The following versions failed: %s, would you like to retry them? [Y/n]: ' % [failed_versions.join(', ')]
        answer = $stdin.gets.strip.downcase
        if answer.empty? || answer == 'y'
          versions = failed_versions
          failed_versions = []
        else
          done = true
        end
      else
        done = true
      end
    end
  end

  namespace :docker do
    task :running do
      docker_binary = %x(which docker 2> /dev/null).strip
      if docker_binary.empty?
        abort 'Unable to find Docker binary. Docker needs to be installed on your system for running these tests.'
      else
        boot2docker_binary = %x(which boot2docker 2> /dev/null).strip
        unless boot2docker_binary.empty?
          boot2docker_status = %x(boot2docker status).strip
          if boot2docker_status != 'running'
            %x(boot2docker stop && boot2docker start)
            unless $?.success?
              abort 'Failed to start boot2docker'
            end
          end
        end
      end
    end
  end
end