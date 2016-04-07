# encoding: utf-8

require 'rspec/core/rake_task'
require 'foodcritic'
require 'stove'
require 'stove/rake_task'

RSpec::Core::RakeTask.new(:spec)
FoodCritic::Rake::LintTask.new do |t|
  t.options = {
    fail_tags: %w[any],
  }
end

desc 'Run FoodCritic and ChefSpec'
task :test do
  Rake::Task['foodcritic'].execute
  Rake::Task['spec'].execute
end

desc 'Package the latest version as a .tar.gz archive'
task :package => :test do
  cookbook = Stove::Cookbook.new(Dir.pwd)
  version = cookbook.tag_version
  release_name = %(kafka-cookbook-#{version})
  archive_path = ::File.join('pkg', sprintf('kafka-cookbook-%s.tar.gz', version))

  if File.exist?(archive_path)
    puts %(#{archive_path} already exist, exiting...)
    exit(1)
  else
    packager = Stove::Packager.new(cookbook, false)
    File.open(archive_path, 'wb') do |f|
      f.write(packager.tarball.read)
    end
    puts %(Created archive of #{version} as #{archive_path})
  end
end

Stove::RakeTask.new do |t|
  t.stove_opts = %w[--no-git]
  t.log_level = :debug
end

class KitchenTask
  attr_reader :output, :duration

  def initialize(version)
    @output = []
    @env = {
      'KAFKA_VERSION' => version,
      'CHEF_VERSION' => ENV['CHEF_VERSION'],
    }
  end

  def run
    start_timestamp = Time.now
    if @concurrency > 1
      status = run_and_wait(sprintf('bundle exec kitchen setup --concurrency=%d', @concurrency))
      if status.success?
        status = run_and_wait('bundle exec kitchen verify')
      end
      run_and_wait(sprintf('bundle exec kitchen destroy --concurrency=%d', @concurrency))
    else
      status = run_and_wait('bundle exec kitchen test')
    end
    @duration = Time.now - start_timestamp
    status
  end

  private

  def run_and_wait(command)
    start_time = Time.now
    rd, wr = IO.pipe
    pid = Process.fork do
      $stdout.reopen(wr)
      rd.close
      exec(@env, command)
    end
    wr.close
    rd.each do |line|
      @output << line
    end
    _, status = Process.waitpid2(pid)
    duration = Time.now - start_time
    puts '>>> Ran %p, in %d seconds' % [command, duration]
    status
  end
end

class DockerTask < KitchenTask
  def initialize(version)
    super(version)
    @env['KITCHEN_YAML'] = '.kitchen.docker.yml'
    @concurrency = ENV.fetch('concurrency', 3).to_i
  end
end

class VagrantTask < KitchenTask
  def initialize(version)
    super(version)
    @env['KITCHEN_YAML'] = '.kitchen.yml'
    @concurrency = ENV.fetch('concurrency', 4).to_i
  end
end

namespace :test do
  default_versions = %w[0.8.1.1 0.8.2.2 0.9.0.1]

  def run_tests_for(versions, task_class)
    puts '>>> Running tests for versions: %s' % [versions.join(', ')]
    failed_versions, done = [], false
    until done do
      versions.each do |version|
        puts '>>> Starting tests for v%s' % version
        task = task_class.new(version)
        if task.run.success?
          puts '>>> Done testing v%s, run took %d seconds' % [version, task.duration]
        else
          puts task.output
          puts '>>> v%s failed, run took %d seconds, see output above ^' % [version, task.duration]
          if ENV.key?('yes')
            answer = ''
          else
            print '>>> Continue with the remaining versions? [Y/n]: '
            answer = $stdin.gets.strip.downcase
          end
          if answer.empty? || answer == 'y'
            failed_versions << version
            next
          else
            break
          end
        end
      end
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

  desc 'Run test-kitchen with kitchen-docker'
  task :docker => 'docker:running' do
    versions = ENV.fetch('versions', default_versions.join(',')).split(',')
    run_tests_for(versions, DockerTask)
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

  desc 'Run test-kitchen with kitchen-vagrant'
  task :vagrant do
    versions = ENV.fetch('versions', default_versions.join(',')).split(',')
    run_tests_for(versions, VagrantTask)
  end
end