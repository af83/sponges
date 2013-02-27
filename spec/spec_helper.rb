# encoding: utf-8
require 'sponges'
require 'sys/proctable'

RSpec.configure do |config|
  def sleep_value
    @sleep_value ||= ENV.fetch('SLEEP_VALUE', 2)
  end

  def worker_name
    '_sponges_test'
  end

  def supervisor_name
    "#{worker_name}_supervisor"
  end

  def childs_name
    "#{worker_name}_child"
  end

  def find_supervisor
    Sys::ProcTable.ps.select {|f| f.cmdline == supervisor_name }.first
  end

  def find_childs
    Sys::ProcTable.ps.select {|f| f.cmdline =~ /^#{childs_name}/ }
  end

  def kill_supervisor
    s = find_supervisor
    Process.kill('HUP', s.pid) if s && s.pid
  end

  def press_sponges
    yield if block_given?
    sleep sleep_value
  end

  config.before(:all) do
    system('spec/worker_runner.rb start -d')
    sleep 1
  end

  config.after(:all) do
    kill_supervisor
  end
end
