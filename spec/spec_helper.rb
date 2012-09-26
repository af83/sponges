# encoding: utf-8
require 'sponges'
require 'sys/proctable'

class Worker
  def run
    sleep rand(20)
    run
  end
end

Sponges.configure do |config|
  config.worker        = Worker.new
  config.worker_name   = "test"
  config.worker_method = :run
end

def find_supervisor
  Sys::ProcTable.ps.select{|f| f.cmdline == 'test_supervisor'}.first
end

def kill_supervisor
  s = find_supervisor
  Process.kill('HUP', s.pid) if s && s.pid
end
