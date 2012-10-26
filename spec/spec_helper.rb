# encoding: utf-8
require 'sponges'
require 'sys/proctable'

RSpec.configure do |config|
  config.before(:all) do
    kill_supervisor
    fork {
      Sponges.start Worker.name, ['start'] do
        Worker.new.run
      end
    }
    sleep 1
  end
end

class Worker
  def self.name
    '_sponges_test'
  end
  def run
    sleep 1
    run
  end
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
