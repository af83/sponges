# encoding: utf-8
require 'sponges'
require 'sys/proctable'

class Worker
  def self.name
    '_sponges_test'
  end
  def run
    trap(:HUP) {
      exit
    }
    sleep 1
    run
  end
end

Sponges.configure do |config|
  config.worker        = Worker.new
  config.worker_name   = Worker.name
  config.worker_method = :run
end

def supervisor_name
  "#{Worker.name}_supervisor"
end

def childs_name
  "#{Worker.name}_child"
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
