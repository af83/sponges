# encoding: utf-8
require 'sponges'
require 'sys/proctable'

RSpec.configure do |config|
  def sleep_value
    @sleep_value ||= ENV.fetch('SLEEP_VALUE', 2).to_i
  end

  def worker_name
    "_sponges_test_#{RUBY_VERSION}"
  end

  def supervisor_name
    "#{worker_name}_test_supervisor"
  end

  def childs_name
    "#{worker_name}_test_child"
  end

  def find_supervisor
    Sys::ProcTable.ps.select {|f| f.cmdline == supervisor_name }.first
  end

  def find_childs
    Sys::ProcTable.ps.select {|f| f.cmdline =~ /^#{childs_name}/ }
  end

  def kill_supervisor
    s = find_supervisor
    Process.kill('QUIT', s.pid) if s && s.pid
  end

  def press_sponges
    yield if block_given?
    sleep sleep_value
  end

  config.before do
    system('spec/worker_runner.rb start -d')
    sleep sleep_value
  end

  config.after do
    kill_supervisor
    sleep sleep_value
  end
end
