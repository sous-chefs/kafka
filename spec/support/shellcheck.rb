# encoding: utf-8

module Shellcheck
  def shellcheck_installed?
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, sprintf('shellcheck%s', ext))
        return true if File.executable?(exe) && !File.directory?(exe)
      end
    end
    nil
  end

  def shellcheck(path, exclude='')
    command_string = 'shellcheck '
    command_string << '-e ' << exclude unless exclude.empty?
    command = Mixlib::ShellOut.new([command_string, path].join(' '))
    command.run_command.error!
  end
end
